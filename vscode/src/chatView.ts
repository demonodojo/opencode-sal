import * as vscode from 'vscode';
import { SuperEvent, Turn, buildPrompt } from './events';
import { Run, startRun } from './runner';
import { State, cfg } from './state';

export class ChatView implements vscode.WebviewViewProvider {
  static readonly viewType = 'supercoder.chat';
  private view?: vscode.WebviewView;
  private run?: Run;
  private history: Turn[] = [];
  constructor(
    private readonly ctx: vscode.ExtensionContext,
    private readonly state: State,
  ) {
    ctx.subscriptions.push(state.onDidChangeModel((m) => this.post({ type: 'model', model: m })));
  }

  resolveWebviewView(view: vscode.WebviewView): void {
    this.view = view;
    view.webview.options = {
      enableScripts: true,
      localResourceRoots: [vscode.Uri.joinPath(this.ctx.extensionUri, 'media')],
    };
    view.webview.html = this.html(view.webview);
    view.webview.onDidReceiveMessage((m) => this.onMessage(m));
    view.onDidDispose(() => {
      this.stop();
      this.view = undefined;
    });
    this.post({ type: 'model', model: this.state.model });
  }

  focus(): Thenable<void> {
    return vscode.commands.executeCommand('supercoder.chat.focus');
  }

  newChat(): void {
    this.stop();
    this.history = [];
    this.post({ type: 'clear' });
  }

  stop(): void {
    this.run?.stop();
    this.run = undefined;
  }

  async insertText(text: string): Promise<void> {
    await this.focus();
    this.post({ type: 'insert', text });
  }

  pickModel(): Promise<void> {
    return this.state.pickModel();
  }

  private onMessage(m: { type: string; text?: string }): void {
    if (m.type === 'send' && m.text) {
      this.send(m.text);
    } else if (m.type === 'stop') {
      this.stop();
    } else if (m.type === 'pickModel') {
      void this.pickModel();
    } else if (m.type === 'newChat') {
      this.newChat();
    }
  }

  private send(text: string): void {
    if (this.run) {
      return;
    }
    const c = cfg();
    const prompt = buildPrompt(this.history, text, c.get<number>('historyTurns', 6));
    let answer = '';
    this.post({ type: 'user', text });
    this.post({ type: 'busy', busy: true });
    this.run = startRun({
      binary: this.state.binary(),
      cwd: this.state.folder(),
      prompt,
      model: this.state.model,
      maxTurns: c.get<number>('maxTurns', 40),
      onEvent: (e: SuperEvent) => {
        if (e.kind === 'text') {
          answer += (answer ? '\n' : '') + e.text;
        }
        this.post({ type: 'event', event: e });
      },
      onDone: (code, stderr) => {
        this.run = undefined;
        if (answer) {
          this.history.push({ user: text, assistant: answer });
        }
        if (code !== 0 && stderr.trim()) {
          this.post({ type: 'event', event: { kind: 'error', message: stderr.trim() } });
        }
        this.post({ type: 'busy', busy: false });
      },
    });
  }

  private post(msg: unknown): void {
    void this.view?.webview.postMessage(msg);
  }

  private html(webview: vscode.Webview): string {
    const uri = (f: string) =>
      webview.asWebviewUri(vscode.Uri.joinPath(this.ctx.extensionUri, 'media', f));
    const nonce = Array.from({ length: 24 }, () => Math.random().toString(36)[2]).join('');
    return `<!doctype html>
<html lang="es"><head><meta charset="utf-8">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src ${webview.cspSource}; script-src 'nonce-${nonce}';">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="${uri('main.css')}">
</head><body>
<header><button id="model" title="Elegir modelo">modelo: por defecto</button><button id="new" title="Nuevo chat">Nuevo</button></header>
<main id="log" aria-live="polite"></main>
<form id="form"><textarea id="input" rows="3" placeholder="Pide algo a supercoder… (Enter envía, Shift+Enter salto)"></textarea>
<div class="row"><button id="send" type="submit">Enviar</button><button id="stop" type="button" hidden>Detener</button></div></form>
<script nonce="${nonce}" src="${uri('main.js')}"></script>
</body></html>`;
  }
}
