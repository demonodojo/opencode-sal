import * as vscode from 'vscode';
import { Turn } from './events';
import { buildPrompt } from './events';
import { filesFromReferences, removeTemp } from './attachments';
import { askPermission } from './permission';
import { startRun } from './runner';
import { State, cfg } from './state';
import { VENDOR, modelFromId } from './provider';

/** Convierte el historial del Chat nativo en turnos usuario/asistente. */
export function turnsFromHistory(history: readonly (vscode.ChatRequestTurn | vscode.ChatResponseTurn)[]): Turn[] {
  const turns: Turn[] = [];
  let user: string | undefined;
  for (const h of history) {
    if (h instanceof vscode.ChatRequestTurn) {
      user = h.prompt;
    } else if (user !== undefined) {
      const answer = h.response
        .map((p) => (p instanceof vscode.ChatResponseMarkdownPart ? p.value.value : ''))
        .join('');
      if (answer) {
        turns.push({ user, assistant: answer });
      }
      user = undefined;
    }
  }
  return turns;
}

export function registerParticipant(ctx: vscode.ExtensionContext, state: State): void {
  const handler: vscode.ChatRequestHandler = async (request, chatCtx, stream, token) => {
    if (request.command === 'model') {
      const wanted = request.prompt.trim();
      if (wanted) {
        state.model = wanted === 'default' ? '' : wanted;
      } else {
        await state.pickModel();
      }
      stream.markdown(`Modelo: \`${state.model || 'por defecto'}\``);
      return;
    }

    // Modelo elegido en el desplegable del chat (si es de supercoder); si no, el de /model.
    if (request.model?.vendor === VENDOR) {
      state.model = modelFromId(request.model.id);
    }
    const c = cfg();
    const prompt = buildPrompt(turnsFromHistory(chatCtx.history), request.prompt, c.get<number>('historyTurns', 6));
    stream.progress(`supercoder (${state.model || 'por defecto'})…`);

    const files = await filesFromReferences(request.references);
    const autoApprove = c.get<boolean>('autoApprove', false);
    await new Promise<void>((resolve) => {
      const run = startRun({
        binary: state.binary(),
        cwd: state.folder(),
        prompt,
        model: state.model,
        maxTurns: c.get<number>('maxTurns', 60),
        sessionId: `vscode-chat-${Date.now().toString(36)}`,
        interactive: !autoApprove,
        yes: autoApprove,
        files,
        onEvent: (e) => {
          if (e.kind === 'text') {
            stream.markdown(e.text + '\n\n');
          } else if (e.kind === 'tool' && e.status === 'running') {
            stream.progress(`herramienta: ${e.tool}`);
          } else if (e.kind === 'subagent' && e.event.kind === 'tool' && e.event.status === 'running') {
            stream.progress(`subagente: ${e.event.tool}`);
          } else if (e.kind === 'permission') {
            void askPermission(e.title).then((r) => run.reply(e.id, r));
          } else if (e.kind === 'error') {
            stream.markdown(`**Error:** ${e.message}\n\n`);
          }
        },
        onDone: (code, stderr) => {
          removeTemp(files);
          if (code !== 0 && stderr.trim()) {
            stream.markdown(`**Error:** ${stderr.trim()}\n\n`);
          }
          resolve();
        },
      });
      token.onCancellationRequested(() => run.stop());
    });
  };

  const p = vscode.chat.createChatParticipant('supercoder.agent', handler);
  p.iconPath = vscode.Uri.joinPath(ctx.extensionUri, 'media', 'icon.svg');
  ctx.subscriptions.push(p);
}
