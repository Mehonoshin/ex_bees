defmodule MapView do
  require EEx

  EEx.function_from_file :def, :html, "lib/web/templates/map.html.eex", [:map_width, :map_height]
end
