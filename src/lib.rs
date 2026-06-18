use std::fs;
use zed_extension_api::{self as zed, Result, process::Command, settings::LspSettings};

const BINARY_NAME: &str = "fish-lsp";
const NPM_SERVER_PATH: &str = "node_modules/fish-lsp/dist/fish-lsp";

struct Fish {}

impl Fish {
    /// Checks if a given file path exists.
    fn exists(path: &str) -> bool {
        fs::metadata(path).is_ok_and(|stat| stat.is_file())
    }

    /// Gets a [`LspSettings`] struct for the given language server & worktree. Convenience wrapper around [`LspSettings::for_worktree`].
    fn get_server_settings(
        language_server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> LspSettings {
        LspSettings::for_worktree(&language_server_id.to_string(), worktree).unwrap_or_default()
    }

    /// Gets an array of arguments to pass to the `fish-lsp` binary.
    ///
    /// If `lsp.fish-lsp.binary.arguments` is not set, this will default to `["start"]`.
    fn get_server_arguments(
        language_server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Vec<String> {
        let settings = Fish::get_server_settings(language_server_id, worktree);

        settings
            .binary
            .and_then(|binary| binary.arguments)
            .unwrap_or_else(|| vec!["start".to_owned()])
    }

    /// Install `fish-lsp` from NPM with the given version.
    fn install_npm_language_server(
        language_server_id: &zed::LanguageServerId,
        package_version: &str,
    ) -> Result<(), String> {
        zed::set_language_server_installation_status(
            language_server_id,
            &zed::LanguageServerInstallationStatus::Downloading,
        );
        let installation_err = zed::npm_install_package(BINARY_NAME, package_version).err();
        if let Some(err) = installation_err {
            zed::set_language_server_installation_status(
                language_server_id,
                &zed::LanguageServerInstallationStatus::Failed(err.clone()),
            );
            return Err(err);
        }

        zed::set_language_server_installation_status(
            language_server_id,
            &zed::LanguageServerInstallationStatus::None,
        );
        Ok(())
    }

    /// Ensure that the NPM `fish-lsp` binary is installed and updated.
    fn ensure_install_npm_language_server_binary(
        language_server_id: &zed::LanguageServerId,
    ) -> Result<()> {
        let installed_version = &zed::npm_package_installed_version(BINARY_NAME)?;
        let latest_version = &zed::npm_package_latest_version(BINARY_NAME)?;

        if installed_version.is_none() {
            Fish::install_npm_language_server(language_server_id, latest_version)?;
            return Ok(());
        }

        zed::set_language_server_installation_status(
            language_server_id,
            &zed::LanguageServerInstallationStatus::CheckingForUpdate,
        );

        if let Some(installed) = installed_version
            && installed != latest_version
        {
            Fish::install_npm_language_server(language_server_id, latest_version)?;
            return Ok(());
        }

        zed::set_language_server_installation_status(
            language_server_id,
            &zed::LanguageServerInstallationStatus::None,
        );
        Ok(())
    }

    /// Finds a path to the `fish-lsp` binary.
    ///
    /// ## Resolution Order
    ///
    /// 1. `lsp.fish-lsp.binary.path`
    /// 2. `PATH` lookup for `fish-lsp`
    /// 3. Install `fish-lsp` from npm (see: `Fish::ensure_install_npm_language_server_binary`)
    fn find_language_server_binary(
        &mut self,
        language_server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<String> {
        if worktree.which("fish").is_none() {
            return Err("fish-lsp requires the fish shell to be installed to function".to_string());
        }

        let settings = Fish::get_server_settings(language_server_id, worktree);

        if let Some(path) = settings.binary.and_then(|binary| binary.path) {
            if Fish::exists(&path) {
                return Ok(path);
            }
        }

        if let Some(path) = worktree.which(BINARY_NAME) {
            return Ok(path);
        }

        Fish::ensure_install_npm_language_server_binary(language_server_id)?;
        if Fish::exists(NPM_SERVER_PATH) {
            return Ok(NPM_SERVER_PATH.to_string());
        }

        return Err("Couldn't locate `fish-lsp` language server binary.".to_string());
    }
}

impl zed::Extension for Fish {
    fn new() -> Self {
        Self {}
    }

    fn language_server_command(
        &mut self,
        language_server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<Command> {
        Ok(Command {
            command: Fish::find_language_server_binary(self, language_server_id, worktree)?,
            args: Fish::get_server_arguments(language_server_id, worktree),
            env: worktree.shell_env(),
        })
    }
}

zed::register_extension!(Fish);
