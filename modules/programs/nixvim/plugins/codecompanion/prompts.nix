{
  delib,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.codecompanion.prompts";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim.plugins.codecompanion.settings.prompt_library = {
    "Text Revision" = {
      strategy = "inline";
      description = "Revise the text";
      opts = {
        mapping = "<leader>rt";
        auto_submit = true;
        user_prompt = false;
        stop_context_insertion = true;
        short_name = "textexpert";
        placement = "replace";
      };
      prompts = [
        {
          role = "system";
          content = ''
            You are a senior text editor specializing in improving written content. 
            Your tasks include: correcting grammar and spelling errors, 
            improving sentence structure, enhancing clarity 
            and flow, making text sound more natural to native speakers, and ensuring proper Markdown formatting. 
            Provide specific explanations for significant changes, 
            maintain the author's original meaning and tone, and focus on making text professional and polished. 
            When possible, offer brief alternative phrasings for improved sections.
          '';
        }
        {
          role = "user";
          content.__raw = ''
            function(context)
              local lines = require('codecompanion.helpers.actions').get_code(1, context.line_count, { show_line_numbers = true })
              local selection_info = ""

              if context.is_visual then
                selection_info = string.format('Currently selected lines: %d-%d', context.start_line, context.end_line)
              else
                selection_info = string.format('Currently selected lines: %d-%d', 1, context.line_count)
              end

              return string.format( 'I have the following text:\n\n```%s\n%s\n```\n\n%s',
                context.filetype,
                lines,
                selection_info
              )
            end'';
        }
      ];
    };
    "Diff code review" = {
      strategy = "chat";
      description = "Perform a code review";
      opts = {
        auto_submit = true;
        user_prompt = false;
      };
      prompts = [
        {
          role = "user";
          content.__raw = ''
            function()
              local target_branch = vim.fn.input("Target branch for merge base diff (default: main): ", "main")

              return string.format(
                [[
                You are a senior software engineer performing a code review. Analyze the following code changes.
                 Identify any potential bugs, performance issues, security vulnerabilities, or areas that could be refactored for better readability or maintainability.
                 Explain your reasoning clearly and provide specific suggestions for improvement.
                 Consider edge cases, error handling, and adherence to best practices and coding standards.
                 Here are the code changes:
                 ```
                  %s
                 ```
                 ]],
                vim.fn.system("git diff --merge-base " .. target_branch)
              )
            end
          '';
        }
      ];
    };
  };
}
