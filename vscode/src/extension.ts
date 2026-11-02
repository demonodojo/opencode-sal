import * as vscode from 'vscode';
import { ChatView } from './chatView';

export function activate(ctx: vscode.ExtensionContext): void {
  const chat = new ChatView(ctx);
  ctx.subscriptions.push(
    vscode.window.registerWebviewViewProvider(ChatView.viewType, chat, {
      webviewOptions: { retainContextWhenHidden: true },
    }),
    vscode.commands.registerCommand('supercoder.openChat', () => chat.focus()),
    vscode.commands.registerCommand('supercoder.newChat', () => chat.newChat()),
    vscode.commands.registerCommand('supercoder.selectModel', () => chat.pickModel()),
    vscode.commands.registerCommand('supercoder.stop', () => chat.stop()),
    vscode.commands.registerCommand('supercoder.sendSelection', async () => {
      const ed = vscode.window.activeTextEditor;
      if (!ed || ed.selection.isEmpty) {
        return;
      }
      const rel = vscode.workspace.asRelativePath(ed.document.uri);
      const s = ed.selection;
      const code = ed.document.getText(s);
      await chat.insertText(`${rel}:${s.start.line + 1}-${s.end.line + 1}\n\`\`\`\n${code}\n\`\`\`\n`);
    }),
  );
}

export function deactivate(): void {}
