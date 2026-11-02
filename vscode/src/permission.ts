import * as vscode from 'vscode';
import { PermissionReply } from './events';

/** Pregunta con un cuadro modal (participante de chat y proveedor de modelos). */
export async function askPermission(title: string): Promise<PermissionReply> {
  const pick = await vscode.window.showWarningMessage(
    `SuperCoder quiere usar: ${title}`,
    { modal: true },
    'Permitir',
    'Siempre',
  );
  return pick === 'Permitir' ? 'once' : pick === 'Siempre' ? 'always' : 'reject';
}
