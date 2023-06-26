# defmodule Tableau.Support.MyData.Http do
#   defstruct [:data]

#   defimpl Tableau.Provider do
#     def fetch(http) do
#       data = Req.get!("http://localhost:9000/books").body

#       %{http | data: data}
#     end
#   end
# end
