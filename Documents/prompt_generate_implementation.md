# I want to build a real, usable iOS app called [App Name].

INPUTS:
- Product description file: [path/to/project_description.md]
- Figma Make design: [Figma Make URL]
- Additional notes (optional): [anything not covered by the description or design, or leave blank]

STEP 1 — Read project rules
First, read and follow the existing CLAUDE.md in this project.

STEP 2 — Read the product description
Read the product description file in full. Treat it as the source of truth for:
- Product goal and target users
- Core features and their behavior
- User flows and business rules
- Technical requirements (APIs, persistence, Camera / Map / AI, etc.)

STEP 3 — Pull the UI design through the Figma MCP
Use the Figma MCP server to inspect the Figma Make project at the link above.
Use tools such as get_design_context, get_screenshot, and get_variable_defs, as available.
Extract:
- Every screen and its purpose
- Navigation structure and screen-to-screen flow
- Reusable components and their states (empty, loading, error, selected, etc.)
- Design tokens: colors, typography, spacing, corner radius
- Icons, images, and other assets the app needs

If the Figma MCP is unavailable or the link cannot be accessed, STOP and tell me.
Do not guess the UI.

STEP 4 — Reconcile the two sources
Compare the description with the design.
- For layout, visuals, and screen structure, the Figma design wins.
- For behavior, data, and business logic, the description wins.
- List any feature that appears in one source but not the other.
- List any open questions instead of silently making assumptions.

STEP 5 — Plan with Superpowers
Use the Superpowers brainstorming and writing-plans skills to analyze and refine
the product requirements, features, user flow, and technical approach,
based on everything gathered in Steps 2–4.

DO NOT start coding.

Create an `implementation.md` that breaks the entire project into small,
sequential, independently executable and verifiable phases.

Requirements for the plan:
- Use NO MORE THAN 10 phases in total.
- Order phases by dependency.
- Give each phase a clear goal and Definition of Done.
- Keep the app buildable and runnable after each phase whenever possible.
- Keep each phase focused; group related work rather than exceeding 10 phases.
- Include appropriate testing and verification in every phase.
- Do not implement functionality belonging to future phases.
- Avoid speculative abstractions and over-engineering.

For each phase, include:
- Goal
- Scope: screens, features, and main files or modules involved
- Figma references: the frames or components this phase implements
- Definition of Done
- Verification: tests to write and manual checks to run

At the top of `implementation.md`, include:
- A short summary of the app, from the description
- A screen inventory, from the Figma design
- Design tokens to set up in the first phase
- Mismatches and open questions found in Step 4

OUTPUT ONLY the completed `implementation.md`.
Do not begin implementation.
