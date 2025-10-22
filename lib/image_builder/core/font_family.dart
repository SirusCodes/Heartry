enum FontFamily {
  caveat("Caveat", "Caveat"),
  lato("Lato", "Lato"),
  tangerine("Tangerine", "Tangerine"),
  dancingScript("DancingScript", "Dancing Script"),
  josefinSans("JosefinSans", "Josefin Sans"),
  lora("Lora", "Lora"),
  monsterrat("Montserrat", "Montserrat"),
  playfairDisplay("PlayfairDisplay", "Playfair Display"),
  quicksand("Quicksand", "Quicksand");

  const FontFamily(this.name, this.displayName);
  final String name;
  final String displayName;
}
