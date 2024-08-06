defmodule B.Functions do
  def now_ns(), do: :erlang.monotonic_time() # nanoseconds 
  def now_us(), do: now_ms()/1000  
  def now_ms(), do: now_ms()/1000_000 
  def now(), do: :erlang.monotonic_time() # nanoseconds 
  def uuid() do
    :erlang.unique_integer() 
    |> to_string()
    |> String.slice(2..-1//1)
  end
  # def pid_to_string(pid), do: :erlang.pid_to_list(pid)
  def pid_to_string(pid), do: inspect pid 
  # def string_to_pid(string), do: :erlang.list_to_pid(string)
  def string_to_pid(string), do: IEx.Helpers.pid(string)

  def deep_graft(%{}=map_left,%{}=map_right) do
    Map.merge(map_left,map_right, fn _,left,right -> deep_graft(left,right) end)
  end
  def deep_graft(_left,right) do
    right
  end
  def arity(some_function), do: :erlang.fun_info(some_function)[:arity]
end

