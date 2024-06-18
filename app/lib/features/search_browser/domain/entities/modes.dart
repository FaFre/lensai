enum KagiTool {
  search,
  summarizer,
  //Sort early access features last
  assistant,
}

enum AssistantMode {
  research(7),
  code(5),
  chat(4),
  custom(6);

  final int value;

  const AssistantMode(this.value);
}

enum ResearchVariant {
  fast(1),
  expert(2);

  final int value;

  const ResearchVariant(this.value);
}

enum ChatModel {
  gpt35Turbo('GPT 3.5 Turbo', 1),
  gpt4('GPT 4', 2),
  gpt4Turbo('GPT 4 Turbo', 7),
  gpt4o('GPT 4o', 15),
  claude3Haiku('Claude 3 Haiku', 13),
  claude3Sonnet('Claude 3 Sonnet', 14),
  claude3Opus('Claude 3 Opus', 12),
  gemini15Pro('Gemini 1.5 Pro', 8),
  mistralSmall('Mistral Small', 10),
  mistralLarge('Mistral Large', 11);

  final int value;
  final String label;

  const ChatModel(this.label, this.value);
}

enum SummarizerMode {
  keyMoments('takeaway'),
  summary('summary');

  final String value;

  const SummarizerMode(this.value);
}
