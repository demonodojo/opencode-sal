import * as vscode from 'vscode';
import { filesFromMessages, removeTemp } from './attachments';
import { modelAcceptsImages } from './events';
import { askPermission } from './permission';
import { startRun } from './runner';
import { State, cfg } from './state';

export const VENDOR = 'supercoder';
export const DEFAULT_ID = 'default';

/** id del selector de modelos -> valor de --model ('' = el por defecto de supercoder). */
export function modelFromId(id: string): string {
  return id === DEFAULT_ID ? '' : id;
}

export function idFromModel(model: string): string {
  return model || DEFAULT_ID;
}

function messageText(m: vscode.LanguageModelChatRequestMessage): string {
  const body = m.content
    .map((p) => (p instanceof vscode.LanguageModelTextPart ? p.value : ''))
    .join('');
  const role = m.role === vscode.LanguageModelChatMessageRole.User ? 'Usuario' : 'Asistente';
  return `${role}: ${body}`;
}

/**
 * Expone los modelos de supercoder (supercoder.json, claude:* y ajustes) en el
 * desplegable de modelos del Chat de VS Code.
 */
export class SuperCoderModels implements vscode.LanguageModelChatProvider {
  private readonly changed = new vscode.EventEmitter<void>();
  readonly onDidChangeLanguageModelChatInformation = this.changed.event;

  constructor(private readonly state: State) {}

  refresh(): void {
    this.changed.fire();
  }

  provideLanguageModelChatInformation(): vscode.LanguageModelChatInformation[] {
    const ids = [DEFAULT_ID, ...this.state.choices()];
    return ids.map((id) => ({
      id,
      name: id === DEFAULT_ID ? 'supercoder (por defecto)' : id,
      family: VENDOR,
      version: '1',
      tooltip: id === DEFAULT_ID ? 'Modelo de supercoder.json o soso-coder' : `supercoder --model ${id}`,
      maxInputTokens: 128000,
      maxOutputTokens: 8192,
      capabilities: { imageInput: modelAcceptsImages(this.state.projectConfig(), id === DEFAULT_ID ? '' : id) },
    }));
  }

  provideLanguageModelChatResponse(
    model: vscode.LanguageModelChatInformation,
    messages: readonly vscode.LanguageModelChatRequestMessage[],
    _options: vscode.ProvideLanguageModelChatResponseOptions,
    progress: vscode.Progress<vscode.LanguageModelResponsePart>,
    token: vscode.CancellationToken,
  ): Thenable<void> {
    const files = filesFromMessages(messages);
    const autoApprove = cfg().get<boolean>('autoApprove', false);
    return new Promise<void>((resolve) => {
      const run = startRun({
        binary: this.state.binary(),
        cwd: this.state.folder(),
        prompt: messages.map(messageText).join('\n\n'),
        model: modelFromId(model.id),
        maxTurns: cfg().get<number>('maxTurns', 60),
        sessionId: `vscode-lm-${Date.now().toString(36)}`,
        interactive: !autoApprove,
        yes: autoApprove,
        files,
        onEvent: (e) => {
          if (e.kind === 'text') {
            progress.report(new vscode.LanguageModelTextPart(e.text + '\n'));
          } else if (e.kind === 'permission') {
            void askPermission(e.title).then((r) => run.reply(e.id, r));
          } else if (e.kind === 'error') {
            progress.report(new vscode.LanguageModelTextPart(`Error: ${e.message}\n`));
          }
        },
        onDone: () => {
          removeTemp(files);
          resolve();
        },
      });
      token.onCancellationRequested(() => run.stop());
    });
  }

  provideTokenCount(_model: vscode.LanguageModelChatInformation, text: string | vscode.LanguageModelChatRequestMessage): Thenable<number> {
    const s = typeof text === 'string' ? text : messageText(text);
    return Promise.resolve(Math.ceil(s.length / 4));
  }
}
