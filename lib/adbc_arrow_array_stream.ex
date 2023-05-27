defmodule Adbc.ArrowArrayStream do
  @moduledoc """
  Documentation for `Adbc.ArrowArrayStream`.
  """

  @typedoc """
  - **reference**: `reference`.

    The underlying erlang resource variable.

  """
  @type t :: %__MODULE__{
          reference: reference()
        }
  defstruct [:reference]
  alias __MODULE__, as: T

  @spec get_pointer(Adbc.ArrowArrayStream.t()) :: binary()
  def get_pointer(self = %T{}) do
    Adbc.Nif.adbc_arrow_array_stream_get_pointer(self.reference)
  end
end
