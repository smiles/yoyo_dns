defmodule YoyoDns do

  @yoyo "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=nohtml&showintro=0&mimetype=plaintext"
  
  def main(_args) do

    {:ok, yoyo_return} = HTTPoison.get(@yoyo)

    if yoyo_return.status_code == 200 do
      process_body(yoyo_return.body)
    else
      Process.sleep(600000)
      YoyoDns.main()
    end 

    exit(:normal)

  end

  defp process_body(body) do

    body_split = String.split(body, "\n")
                 |> List.delete("")

    dns = return_dns(body_split, "") 
    File.write!("/etc/bind/adserver.zones", dns)
  end 

  defp return_dns([head | tail], result) do

   return_dns(tail, result  <> "zone \"" <> head <> "\" {type master; file \"/etc/bind/zones/master/blockdomains.db\";};\n")

  end

  defp return_dns([], result) do

    result

  end 

end
