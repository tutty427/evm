defmodule EVM.Operation.BlockInformation do
  alias EVM.Operation
  alias EVM.Interface.BlockInterface

  @doc """
  Get the hash of one of the 256 most recent complete blocks.

  # TODO: Test 256 limit

  ## Examples

      iex> block_b = %Block.Header{number: 2, parent_hash: "block_a"}
      iex> block_a = %Block.Header{number: 1, parent_hash: "gen_block"}
      iex> genesis_block = %Block.Header{number: 0, parent_hash: <<0x00::256>>}
      iex> block_map = %{"gen_block" => genesis_block, "block_a" => block_a, "block_b" => block_b}
      iex> block_interface = EVM.Interface.Mock.MockBlockInterface.new(block_b, block_map)
      iex> exec_env = %EVM.ExecEnv{block_interface: block_interface}
      iex> EVM.Operation.BlockInformation.blockhash([3], %{exec_env: exec_env})
      0
      iex> EVM.Operation.BlockInformation.blockhash([2], %{exec_env: exec_env})
      0
      iex> EVM.Operation.BlockInformation.blockhash([1], %{exec_env: exec_env})
      "block_a"
      iex> EVM.Operation.BlockInformation.blockhash([0], %{exec_env: exec_env})
      "gen_block"
      iex> EVM.Operation.BlockInformation.blockhash([-1], %{exec_env: exec_env})
      0
  """
  @spec blockhash(Operation.stack_args, Operation.vm_map) :: Operation.op_result
  def blockhash([block_number], %{exec_env: exec_env}) do
    current_block_header = BlockInterface.get_block_header(exec_env.block_interface)
    parent_block_header = BlockInterface.get_block_by_hash(exec_env.block_interface, current_block_header.parent_hash)

    get_block_number(exec_env.block_interface, parent_block_header, current_block_header.parent_hash, block_number, 0)
  end

  defp get_block_number(block_interface, block_header, parent_hash, block_number, depth) do
    cond do
      block_number > block_header.number or depth == 256 or parent_hash == <<0::256>> -> 0
      block_number == block_header.number -> parent_hash
      true ->
        parent_block_header = BlockInterface.get_block_by_hash(block_interface, block_header.parent_hash)

        case parent_block_header do
          nil -> 0 # block not found
          _ -> get_block_number(block_interface, parent_block_header, block_header.parent_hash, block_number, depth + 1)
        end
    end
  end

  @doc """
  Get the block's beneficiary address.

  ## Examples

      iex> block_interface = EVM.Interface.Mock.MockBlockInterface.new(%Block.Header{beneficiary: <<0x55::160>>})
      iex> exec_env = %EVM.ExecEnv{block_interface: block_interface}
      iex> EVM.Operation.BlockInformation.coinbase([], %{exec_env: exec_env})
      <<0x55::160>>
  """
  @spec coinbase(Operation.stack_args, Operation.vm_map) :: Operation.op_result
  def coinbase(_args, %{exec_env: exec_env}) do
    block_header = BlockInterface.get_block_header(exec_env.block_interface)

    block_header.beneficiary
  end

  @doc """
  Get the block's timestamp

  ## Examples

      iex> block_interface = EVM.Interface.Mock.MockBlockInterface.new(%Block.Header{timestamp: 1_000_000})
      iex> exec_env = %EVM.ExecEnv{block_interface: block_interface}
      iex> EVM.Operation.BlockInformation.timestamp([], %{exec_env: exec_env})
      1_000_000
  """
  @spec timestamp(Operation.stack_args, Operation.vm_map) :: Operation.op_result
  def timestamp(_args, %{exec_env: exec_env}) do
    block_header = BlockInterface.get_block_header(exec_env.block_interface)

    block_header.timestamp
  end

  @doc """
  Get the block's number

  ## Examples

      iex> block_interface = EVM.Interface.Mock.MockBlockInterface.new(%Block.Header{number: 1_500_000})
      iex> exec_env = %EVM.ExecEnv{block_interface: block_interface}
      iex> EVM.Operation.BlockInformation.number([], %{exec_env: exec_env})
      1_500_000
  """
  @spec number(Operation.stack_args, Operation.vm_map) :: Operation.op_result
  def number(_args, %{exec_env: exec_env}) do
    block_header = BlockInterface.get_block_header(exec_env.block_interface)

    block_header.number
  end

  @doc """
  Get the block's difficulty

  ## Examples

      iex> block_interface = EVM.Interface.Mock.MockBlockInterface.new(%Block.Header{difficulty: 2_000_000})
      iex> exec_env = %EVM.ExecEnv{block_interface: block_interface}
      iex> EVM.Operation.BlockInformation.difficulty([], %{exec_env: exec_env})
      2_000_000
  """
  @spec difficulty(Operation.stack_args, Operation.vm_map) :: Operation.op_result
  def difficulty(_args, %{exec_env: exec_env}) do
    block_header = BlockInterface.get_block_header(exec_env.block_interface)

    block_header.difficulty
  end

  @doc """
  Get the block's gas limit.

  ## Examples

      iex> block_interface = EVM.Interface.Mock.MockBlockInterface.new(%Block.Header{gas_limit: 3_000_000})
      iex> exec_env = %EVM.ExecEnv{block_interface: block_interface}
      iex> EVM.Operation.BlockInformation.gaslimit([], %{exec_env: exec_env})
      3_000_000
  """
  @spec gaslimit(Operation.stack_args, Operation.vm_map) :: Operation.op_result
  def gaslimit(_args, %{exec_env: exec_env}) do
    block_header = BlockInterface.get_block_header(exec_env.block_interface)

    block_header.gas_limit
  end

end