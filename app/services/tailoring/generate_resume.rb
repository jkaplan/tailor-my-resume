module Tailoring
  class GenerateResume
    Result = Struct.new(:content, :rationale)

    MODES = %w[ats human].freeze

    BASE_PROMPT = <<~PROMPT
      You are a resume-tailoring assistant helping a real job seeker adapt their
      master resume for a specific job posting. Rules:

      - Never invent experience, employers, titles, or skills that are not present
        in the master resume. You may rephrase, reorder, re-emphasize, and cut,
        but not fabricate.
      - Write ATS-safe Markdown: plain headings and bullet lists, no tables, no
        multi-column layouts, no images.
      - Keep it to roughly one page of content.
    PROMPT

    MODE_PROMPTS = {
      "ats" => <<~PROMPT,
        This resume will likely be screened by an Applicant Tracking System (ATS)
        before any human sees it, so optimize for passing that automated screen:

        - Mirror important terminology from the job description where the
          candidate's real experience genuinely supports it (e.g. match "project
          management" vs "program management" to whichever the posting uses, and
          match an acronym to its spelled-out form or vice versa if that's what
          the posting uses), so keyword-matching software recognizes the overlap.
        - Naturally work in the job posting's key required skills and
          qualifications wherever the candidate genuinely has them.
        - Use conventional section headers (e.g. "Experience", "Education",
          "Skills") since nonstandard headers can fail to parse correctly.
      PROMPT
      "human" => <<~PROMPT
        This resume is likely to be read directly by a hiring manager or
        recruiter rather than screened by automated keyword matching first, so
        optimize for how it reads to a person:

        - Write natural, compelling prose and bullet points that tell a coherent
          story of impact, rather than mechanically mirroring job-description
          keywords.
        - Don't force-fit the job posting's exact terminology if it would read
          awkwardly; use it only where it flows naturally from the candidate's
          real experience.
        - Emphasize the achievements most relevant and interesting to a human
          reader making a quick judgment call.
      PROMPT
    }.freeze

    def initialize(application, master_resume: MasterResume.current, mode: "ats")
      raise ArgumentError, "invalid mode: #{mode}" unless MODES.include?(mode)

      @application = application
      @master_resume = master_resume
      @mode = mode
    end

    def call
      response = client.messages.create(
        model: "claude-sonnet-5",
        max_tokens: 4096,
        system: system_prompt,
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

    attr_reader :application, :master_resume, :mode

    def client
      @client ||= Anthropic::Client.new
    end

    def system_prompt
      BASE_PROMPT + "\n" + MODE_PROMPTS.fetch(mode)
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
