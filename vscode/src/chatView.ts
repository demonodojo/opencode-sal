import * as path from 'path';
import * as vscode from 'vscode';
import { PermissionReply, SuperEvent } from './events';
import { removeTemp, saveTempImage } from './attachments';
import { Run, startRun } from './runner';
import { State, cfg } from './state';

interface WebviewMessage {
  type: string;
  text?: string;
  id?: string;
  reply?: PermissionReply;
  mime?: string;
  data?: string;
  file?: string;
}

export class ChatView implements vscode.WebviewViewProvider {
  static readonly viewType = 'supercoder.chat';
  private view?: vscode.WebviewView;
  private run?: Run;
  private sessionId = newSessionId();
  private turns = 0;
  private attached: string[] = [];

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
    view.webview.onDidReceiveMessage((m: WebviewMessage) => this.onMessage(m));
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
    removeTemp(this.attached);
    this.attached = [];
    this.sessionId = newSessionId();
    this.turns = 0;
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

  /** Adjunta ficheros desde el explorador de VS Code. */
  async attachFiles(): Promise<void> {
    const picked = await vscode.window.showOpenDialog({ canSelectMany: true, defaultUri: vscode.Uri.file(this.state.folder()) });
    this.addAttachments((picked ?? []).map((u) => u.fsPath));
  }

  private addAttachments(files: string[]): void {
    for (const f of files) {
      if (!this.attached.includes(f)) {
        this.attached.push(f);
      }
    }
    this.post({ type: 'attached', files: this.attached.map((f) => ({ path: f, name: path.basename(f) })) });
  }

  private onMessage(m: WebviewMessage): void {
    if (m.type === 'send' && m.text) {
      this.send(m.text);
    } else if (m.type === 'stop') {
      this.stop();
    } else if (m.type === 'pickModel') {
      void this.pickModel();
    } else if (m.type === 'newChat') {
      this.newChat();
    } else if (m.type === 'permissionReply' && m.id && m.reply) {
      this.run?.reply(m.id, m.reply);
    } else if (m.type === 'attachFiles') {
      void this.attachFiles();
    } else if (m.type === 'attachImage' && m.data && m.mime) {
      const f = saveTempImage(Buffer.from(m.data, 'base64'), m.mime);
      if (f) {
        this.addAttachments([f]);
      }
    } else if (m.type === 'detach' && m.file) {
      removeTemp([m.file]);
      this.attached = this.attached.filter((f) => f !== m.file);
      this.addAttachments([]);
    }
  }

  private send(text: string): void {
    if (this.run) {
      return;
    }
    const c = cfg();
    const files = this.attached;
    this.attached = [];
    this.post({ type: 'user', text, files: files.map((f) => path.basename(f)) });
    this.post({ type: 'attached', files: [] });
    this.post({ type: 'busy', busy: true });
    const autoApprove = c.get<boolean>('autoApprove', false);
    this.run = startRun({
      binary: this.state.binary(),
      cwd: this.state.folder(),
      prompt: text,
      model: this.state.model,
      maxTurns: c.get<number>('maxTurns', 60),
      sessionId: this.sessionId,
      cont: this.turns > 0,
      interactive: !autoApprove,
      yes: autoApprove,
      files,
      onEvent: (e: SuperEvent) => this.post({ type: 'event', event: e }),
      onDone: (code, stderr) => {
        this.run = undefined;
        this.turns += 1;
        removeTemp(files);
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
<form id="form"><div id="chips"></div><textarea id="input" rows="3" placeholder="Pide algo a supercoder… (Enter envía, Shift+Enter salto; pega imágenes con Ctrl+V)"></textarea>
<div class="row"><button id="send" type="submit">Enviar</button><button id="attach" type="button" title="Adjuntar ficheros">Adjuntar</button><button id="stop" type="button" hidden>Detener</button></div></form>
<script nonce="${nonce}" src="${uri('main.js')}"></script>
</body></html>`;
  }
}

function newSessionId(): string {
  return `vscode-${Date.now().toString(36)}${Math.random().toString(36).slice(2, 6)}`;
}
