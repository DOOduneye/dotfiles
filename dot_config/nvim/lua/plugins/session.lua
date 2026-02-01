return {
  {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
      log_level = "error",
      auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
      auto_save_enabled = true,
      auto_restore_enabled = true,
      auto_session_use_git_branch = true, -- separate session per branch
    },
  },
}
