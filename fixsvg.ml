

let processArguments () =
   let paths = ref [] in
   let isdir = ref false in
   let opts = [ "-dir", (Arg.Unit (fun () -> isdir := true)), " The paths are directories (default: off)" ] in
   let () = Arg.parse opts (fun a -> paths := a :: !paths) "Usage: fixsvg path [options]\noptions:" in
   let () = paths := List.rev !paths in
   !paths, !isdir

let getSvgFiles path isdir =
   if isdir then
      List.map (fun p -> Sys.readdir p |> Array.map (Filename.concat p)) path
      |> List.map Array.to_list
      |> List.flatten
      |> List.filter (fun a -> Filename.check_suffix a "svg")
   else
      path

let isDefs xml =
   match xml with
   | Xml.Element ("defs", _, _) -> true
   | _ -> false

let rec fixSvg xml =
   match xml with
   | Xml.Element ("svg", attr, children) ->
      let defs, other = List.partition isDefs children in
      Xml.Element ("svg", attr, defs @ other)
   | Xml.Element (tag, attr, children) ->
      let children = List.map fixSvg children in
      Xml.Element (tag, attr, children)
   | _ -> xml


let fixFile file =
   let () = print_endline ("processing " ^ file) in
   let parser = XmlParser.make () in
   let () = XmlParser.prove parser false in
   let x = XmlParser.parse parser (XmlParser.SFile file) in
   let fixed = Xml.to_string_fmt (fixSvg x) in
   let oc = open_out file in
   let () = output_string oc fixed in
   let () = close_out oc in
   ()

let main () =
   let paths, isdir = processArguments () in
   let files = getSvgFiles paths isdir in
   List.iter fixFile files
;;
main ()