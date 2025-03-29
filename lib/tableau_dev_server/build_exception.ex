defmodule TableauDevServer.BuildException do
  @moduledoc false
  @type t :: %__MODULE__{
          page: map(),
          exception: any()
        }

  defexception [:page, :exception]

  @impl true
  def exception(page: page, exception: exception) do
    %__MODULE__{page: page, exception: exception}
  end

  @impl true
  def message(%__MODULE__{page: page, exception: exception}) do
    exception =
      if is_binary(exception) do
        String.replace(exception, ~r/\x1B\[[0-9;]*m/, "")
      else
        exception
      end

    """
    An exception was raised:
      #{Exception.format_banner(:error, exception)}

    occurred during the build process on the page:
      #{inspect(page, pretty: true)}
    """
  end
end
