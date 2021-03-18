%dw 2.0
fun parse_cpu(val: String) =
  if (val matches /[0-9]*m/) (val match /([0-9]*)m/)[1] as Number
  else (val as Number) * 1000
fun parse_memory(val: String) =
  if (val matches /[0-9]*Mi/) floor((val match /([0-9]*)Mi/)[1] as Number)
  else if (val matches /[0-9]*Gi/) floor((val match /([0-9]*)Gi/)[1] as Number * 1024)
  else if (val matches /[0-9]*Ki/) floor((val match /([0-9]*)Ki/)[1] as Number / 1024)
  else floor((val as Number) * 1000)