import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';
import * as vscode from 'vscode';

const EXT: Record<string, string> = {
  'image/png': 'png',
  'image/jpeg': 'jpg',
  'image/gif': 'gif',
  'image/webp': 'webp',
};

export function imageExtension(mime: string): string | undefined {
  return EXT[mime.toLowerCase()];
}

/** Guarda una imagen en un fichero temporal para pasarla con `--file`. */
export function saveTempImage(data: Uint8Array, mime: string): string | undefined {
  const ext = imageExtension(mime);
  if (!ext) {
    return undefined;
  }
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'supercoder-img-'));
  const file = path.join(dir, `imagen.${ext}`);
  fs.writeFileSync(file, data);
  return file;
}

export function removeTemp(files: string[]): void {
  for (const f of files) {
    if (path.basename(path.dirname(f)).startsWith('supercoder-img-')) {
      try {
        fs.rmSync(path.dirname(f), { recursive: true, force: true });
      } catch {
        /* ya no existe */
      }
    }
  }
}

/** Referencias de una petición de chat (ficheros, selecciones, imágenes) -> rutas para `--file`. */
export async function filesFromReferences(refs: readonly vscode.ChatPromptReference[]): Promise<string[]> {
  const out: string[] = [];
  for (const r of refs) {
    const v: any = r.value;
    if (v instanceof vscode.Uri) {
      out.push(v.fsPath);
    } else if (v && v.uri instanceof vscode.Uri) {
      out.push(v.uri.fsPath);
    } else if (v && typeof v.data === 'function' && typeof v.mimeType === 'string') {
      const data: Uint8Array = await v.data();
      const f = saveTempImage(data, v.mimeType);
      if (f) {
        out.push(f);
      }
    }
  }
  return out.filter((f, i) => out.indexOf(f) === i);
}

/** Imágenes de los mensajes de `LanguageModelChat` (partes de datos) -> ficheros temporales. */
export function filesFromMessages(messages: readonly vscode.LanguageModelChatRequestMessage[]): string[] {
  const out: string[] = [];
  for (const m of messages) {
    for (const p of m.content as readonly any[]) {
      if (p && p.data instanceof Uint8Array && typeof p.mimeType === 'string') {
        const f = saveTempImage(p.data, p.mimeType);
        if (f) {
          out.push(f);
        }
      }
    }
  }
  return out;
}
