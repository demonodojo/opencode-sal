import * as fs from 'fs';
import * as path from 'path';
import * as vscode from 'vscode';
import { SuperEvent, Turn, buildPrompt, modelChoices } from './events';
import { Run, startRun } from './runner';

export class ChatView implements vscode.WebviewViewProvider {
  static readonly viewType = 'supercoder.chat';
  private view?: vscode.WebviewView;
  private run?: Run;
  private history: Turn[] = [];
  private model: string;

  constructor(private readonly ctx: vscode.ExtensionContext) {
    this.model = cfg().get<string>('model', '');
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
    this.post({ type: 'model', model: this.model });
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

  async pickModel(): Promise<void> {
    const items = modelChoices(this.readProjectConfig(), cfg().get<string[]>('models', []));
    const pick = await vscode.window.showQuickPick(
      [{ label: '(por defecto)', description: 'supercoder.json o soso-coder', model: '' }].concat(
        items.map((m) => ({ label: m, description: '', model: m })),
      ),
      { placeHolder: `Modelo actual: ${this.model || 'por defecto'}` },
    );
    if (pick) {
      this.model = pick.model;
      this.post({ type: 'model', model: this.model });
    }
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
    const folder = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath ?? process.cwd();
    const c = cfg();
    const prompt = buildPrompt(this.history, text, c.get<number>('historyTurns', 6));
    let answer = '';
    this.post({ type: 'user', text });
    this.post({ type: 'busy', busy: true });
    this.run = startRun({
      binary: c.get<string>('binaryPath', 'supercoder'),
      cwd: folder,
      prompt,
      model: this.model || c.get<string>('model', ''),
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

  private readProjectConfig(): string | undefined {
    const folder = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
    if (!folder) {
      return undefined;
    }
    try {
      return fs.readFileSync(path.join(folder, 'supercoder.json'), 'utf8');
    } catch {
      return undefined;
    }
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

function cfg(): vscode.WorkspaceConfiguration {
  return vscode.workspace.getConfiguration('supercoder');
}
