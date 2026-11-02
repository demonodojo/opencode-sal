import * as fs from 'fs';
import * as path from 'path';
import * as vscode from 'vscode';
import { modelChoices } from './events';

/** Dónde compila supercoder dentro del proyecto (build.sh). */
export const BUILD_BIN = path.join('out', 'linux', 'bin', 'supercoder');

export function cfg(): vscode.WorkspaceConfiguration {
  return vscode.workspace.getConfiguration('supercoder');
}

/** Estado común al panel y al participante de chat: modelo y binario. */
export class State {
  private readonly changed = new vscode.EventEmitter<string>();
  readonly onDidChangeModel = this.changed.event;
  private current: string;

  constructor() {
    this.current = cfg().get<string>('model', '');
  }

  get model(): string {
    return this.current;
  }

  set model(m: string) {
    this.current = m;
    this.changed.fire(m);
  }

  folder(): string {
    return vscode.workspace.workspaceFolders?.[0]?.uri.fsPath ?? process.cwd();
  }

  /** Ajuste explícito > out/linux/bin/supercoder del workspace > 'supercoder' en el PATH. */
  binary(): string {
    const set = cfg().get<string>('binaryPath', '').trim();
    if (set) {
      return set;
    }
    const built = path.join(this.folder(), BUILD_BIN);
    return fs.existsSync(built) ? built : 'supercoder';
  }

  projectConfig(): string | undefined {
    try {
      return fs.readFileSync(path.join(this.folder(), 'supercoder.json'), 'utf8');
    } catch {
      return undefined;
    }
  }

  choices(): string[] {
    return modelChoices(this.projectConfig(), cfg().get<string[]>('models', []));
  }

  async pickModel(): Promise<void> {
    const pick = await vscode.window.showQuickPick(
      [{ label: '(por defecto)', description: 'supercoder.json o soso-coder', model: '' }].concat(
        this.choices().map((m) => ({ label: m, description: '', model: m })),
      ),
      { placeHolder: `Modelo actual: ${this.model || 'por defecto'}` },
    );
    if (pick) {
      this.model = pick.model;
    }
  }
}
