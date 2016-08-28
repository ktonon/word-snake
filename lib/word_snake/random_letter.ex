defmodule WordSnake.RandomLetter do
  @freq [{"E", 0.1202},
        {"T", 0.0910},
        {"A", 0.0812},
        {"O", 0.0768},
        {"I", 0.0731},
        {"N", 0.0695},
        {"S", 0.0628},
        {"R", 0.0602},
        {"H", 0.0592},
        {"D", 0.0432},
        {"L", 0.0398},
        {"U", 0.0288},
        {"C", 0.0271},
        {"M", 0.0261},
        {"F", 0.0230},
        {"Y", 0.0211},
        {"W", 0.0209},
        {"G", 0.0203},
        {"P", 0.0182},
        {"B", 0.0149},
        {"V", 0.0111},
        {"K", 0.0069},
        {"X", 0.0017},
        {"Q", 0.0011},
        {"J", 0.0010},
        {"Z", 0.0007}]

  def random_letter do
    [next | rest] = @freq
    {letter, sum} = next
    lookup_letter(letter, :random.uniform, sum, rest)
  end

  defp lookup_letter(letter, val, sum, freq) do
    if val <= sum || Enum.empty? freq do
      letter
    else
      [next | rest] = freq
      {next_letter, x} = next
      lookup_letter(next_letter, val, sum + x, rest)
    end
  end
end
