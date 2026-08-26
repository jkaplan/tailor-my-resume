module Tailoring
  class GenerateResume
    Result = Struct.new(:content, :rationale)

    SYSTEM_PROMPT = <<~PROMPT.freeze
      You are a resume-tailoring assistant helping a real job seeker adapt their
      master resume for a specific job posting. Rules:

      - Never invent experience, employers, titles, or skills that are not present
        in the master resume. You may rephrase, reorder, re-emphasize, and cut,
        but not fabricate.
      - Write ATS-safe Markdown: plain headings and bullet lists, no tables, no
        multi-column layouts, no images.
      - Mirror important terminology from the job description where the
        candidate's real experience genuinely supports it (e.g. match "project
        management" vs "program management" to whichever the posting uses, if
        the candidate has done that work).
      - Keep it to roughly one page of content.
    PROMPT

    def initialize(application, master_resume: MasterResume.current)
      @application = application
      @master_resume = master_resume
    end

    def call
      response = client.messages.create(
        model: "claude-sonnet-5",
        max_tokens: 4096,
        system: SYSTEM_PROMPT,
        tools: [ tool_definition ],
        tool_choice: { type: "tool", name: "submit_tailored_resume" },
        messages: [ { role: "user", content: prompt } ]
      )

      tool_use = response.content.find { |block| block.type == :tool_use }
      raise "Claude did not return a tailored resume" unless tool_use

      input = tool_use.input
      Result.new(input["resume_markdown"] || input[:resume_markdown],
                 input["rationale"] || input[:rationale])
    end

    private

    attr_reader :application, :master_resume

    def client
      @client ||= Anthropic::Client.new
    end

    def prompt
      <<~PROMPT
        ## Master resume

        #{master_resume.content}

        ## Target role

        Company: #{application.company}
        Role: #{application.role_title}

        ## Job description

        #{application.job_description}

        ---

        Tailor the master resume above for this specific role. Call the
        submit_tailored_resume tool with the tailored resume and a short
        rationale explaining what you emphasized, reordered, or cut, and which
        keywords from the job description you matched.
      PROMPT
    end

    def tool_definition
      {
        name: "submit_tailored_resume",
        description: "Submit the tailored resume and the rationale behind the edits.",
        input_schema: {
          type: "object",
          properties: {
            resume_markdown: {
              type: "string",
              description: "The full tailored resume, in Markdown."
            },
            rationale: {
              type: "string",
              description: "What was emphasized, reordered, or cut, and which job-description keywords were matched."
            }
          },
          required: [ "resume_markdown", "rationale" ]
        }
      }
    end
  end
end
