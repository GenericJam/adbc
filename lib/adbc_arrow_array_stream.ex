defmodule Adbc.ArrowArrayStream do
  @moduledoc """
  Documentation for `Adbc.ArrowArrayStream`.
  """

  @typedoc """
  - **reference**: `reference`.

    The underlying erlang resource variable.

  """
  @type t :: %__MODULE__{
          reference: reference(),
          pointer: non_neg_integer()
        }
  defstruct [:reference, :pointer]
  alias __MODULE__, as: T
  alias Adbc.ArrowSchema

  @spec get_pointer(Adbc.ArrowArrayStream.t()) :: non_neg_integer()
  def get_pointer(self = %T{}) do
    Adbc.Nif.adbc_arrow_array_stream_get_pointer(self.reference)
  end

  @spec get_schema(Adbc.ArrowArrayStream.t()) ::
          {:ok, Adbc.ArrowSchema.t()} | {:error, String.t()} | Adbc.Error.adbc_error()
  def get_schema(self = %T{}) do
    case Adbc.Nif.adbc_arrow_array_stream_get_schema(self.reference) do
      {:ok, schema_ref, {format, name, metadata, flags, n_children}} ->
        {:ok,
         %ArrowSchema{
           format: format,
           name: name,
           metadata: metadata,
           flags: flags,
           n_children: n_children,
           reference: schema_ref
         }}

      other ->
        other
    end
  end
end
