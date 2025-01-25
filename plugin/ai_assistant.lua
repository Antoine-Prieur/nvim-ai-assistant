require("ai_assistant").setup({
	api_key = os.getenv("ANTHROPIC_API_KEY"),
	model = "claude-3-5-sonnet-20241022",
})
