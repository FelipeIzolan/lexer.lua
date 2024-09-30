return {
  { data = "--",                                                        range = { 1, 2 },     type = "comment:start" },
  { data = " Hello, World!",                                            range = { 3, 16 },    type = "comment" },
  { data = "\n",                                                        range = { 17, 17 },   type = "comment:end" },
  { data = [[--[[]],                                                    range = { 18, 21 },   type = "comment:start" },
  { data = " Thank you Mario! But our princess is in another castle! ", range = { 22, 78 },   type = "comment" },
  { data = "]]",                                                        range = { 79, 80 },   type = "comment:end" },
  { data = "local",                                                     range = { 82, 86 },   type = "keyword" },
  { data = "test",                                                      range = { 88, 91 },   type = "identifier" },
  { data = "--",                                                        range = { 93, 94 },   type = "comment:start" },
  { data = " The end of this sentence doesn't have a line-break.",      range = { 95, 146 },  type = "comment" },
  { data = "\n",                                                        range = { 147, 147 }, type = "comment:end" }
}
