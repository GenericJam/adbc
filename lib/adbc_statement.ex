defmodule Adbc.Statement do
  @typedoc """
  - **reference**: `reference`.

    The underlying erlang resource variable.

  """
  @type t :: %__MODULE__{
          reference: reference()
        }
  defstruct [:reference]
  alias __MODULE__, as: T
  alias Adbc.ArrowArrayStream

  @doc """
  Create a new statement for a given connection.
  """
  @doc group: :adbc_statement
  @spec new(Adbc.Connection.t()) :: {:ok, Adbc.Statement.t()} | Adbc.Error.adbc_error()
  def new(connection) do
    case Adbc.Nif.adbc_statement_new(connection.reference) do
      {:ok, ref} ->
        {:ok, %T{reference: ref}}

      {:error, {reason, code, sql_state}} ->
        {:error, {reason, code, sql_state}}
    end
  end

  @doc """
  Destroy a statement.

  ##### Positional Parameter

  - `self`: `Adbc.Statement.t()`

    The statement to release.

  """
  @doc group: :adbc_statement
  @spec release(Adbc.Statement.t()) :: :ok | Adbc.Error.adbc_error()
  def release(self = %T{}) do
    Adbc.Nif.adbc_statement_release(self.reference)
  end

  @doc """
  Execute a statement and get the results.

  This invalidates any prior result sets.

  ##### Positional Parameter

  - `self`: `Adbc.Statement.t()`

    The statement to release.
  """
  @doc group: :adbc_statement
  @spec execute_query(Adbc.Statement.t()) ::
          {:ok, Adbc.ArrowArrayStream.t(), integer()} | Adbc.Error.adbc_error()
  def execute_query(self = %T{}) do
    case Adbc.Nif.adbc_statement_execute_query(self.reference) do
      {:ok, array_stream_ref, rows_affected} ->
        {:ok, %ArrowArrayStream{reference: array_stream_ref}, rows_affected}

      {:error, {reason, code, sql_state}} ->
        {:error, {reason, code, sql_state}}
    end
  end

  @doc """
  Turn this statement into a prepared statement to be
  executed multiple times.

  This invalidates any prior result sets.

  ##### Positional Parameter

  - `self`: `Adbc.Statement.t()`

    A valid `Adbc.Statement.t()`
  """
  @doc group: :adbc_statement
  @spec prepare(Adbc.Statement.t()) :: :ok | Adbc.Error.adbc_error()
  def prepare(self = %T{}) do
    Adbc.Nif.adbc_statement_prepare(self.reference)
  end

  @doc """
  Set the SQL query to execute.

  The query can then be executed with `Adbc.Statement.execute/1`.  For
  queries expected to be executed repeatedly, `Adbc.Statement.prepare/1`
  the statement first.

  ##### Positional Parameter

  - `self`: `Adbc.Statement.t()`

    The statement.

  - `query`: `String.t()`

    The query to execute.

  """
  @doc group: :adbc_statement_sql
  @spec set_sql_query(Adbc.Statement.t(), String.t()) :: :ok | Adbc.Error.adbc_error()
  def set_sql_query(self = %T{}, query) when is_binary(query) do
    Adbc.Nif.adbc_statement_set_sql_query(self.reference, query)
  end

  @doc """
  Set the Substrait plan to execute.

  The query can then be executed with `Adbc.Statement.execute/1`.  For
  queries expected to be executed repeatedly, `Adbc.Statement.prepare/1`
  the statement first.

  ##### Positional Parameter

  - `self`: `Adbc.Statement.t()`

    The statement.

  - `plan`: `String.t()`

    The serialized substrait.Plan to execute.

  - `length`: `non_neg_integer()`

    The length of the serialized plan.

    Defaults to `byte_size(plan)`.
  """
  @doc group: :adbc_statement_substrait
  @spec set_substrait_plan(Adbc.Statement.t(), binary(), non_neg_integer() | :auto) ::
          :ok | Adbc.Error.adbc_error()
  def set_substrait_plan(self = %T{}, plan, length \\ :auto)
      when is_binary(plan) and ((is_integer(length) and length > 0) or length == :auto) do
    length =
      if length == :auto do
        byte_size(plan)
      else
        if length > byte_size(plan) do
          raise RuntimeError,
                "parameter `length` > bytes of acutal size of `plan` (#{byte_size(plan)})"
        else
          length
        end
      end

    Adbc.Nif.adbc_statement_set_substrait_plan(self.reference, plan, length)
  end
end
