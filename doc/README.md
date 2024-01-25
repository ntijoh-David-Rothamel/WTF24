# Kasinojämförelse

## Beskrivning

Här beskriver du applikationens funktionalitet.

### Exempel (ta bort)

Book-O-Matic är en applikation där användare kan skapa virtuella bokhyllor. De kan mata in vilka böcker de har, och information om dessa. Man kan betygssätta böcker och skriva kommentarer. Om en bok är inlagd av en annan användare kan andra användare lägga till den i "sin" bokhylla, och skriva egna kommentarer och recensioner och sätta egna betyg. Man kan söka efter titlar och se kommentarer, recensioner och betyg

## Användare och roller

Här skriver du ner vilka typer av användare (som i inloggade användare) det finns, och vad de har för rättigheter, det vill säga, vad de kan göra (tänk admin, standard användare, etc).

### Exempel (ta bort)

Gästanvändare - oinloggad
. Kan söka efter titlar och se genomsnittligt betyg. Kan inte se eller skriva kommentarer eller sätta egna betyg.

Standardanvändare - inloggad. Kan allt gästanvändare kan, men kan även lägga in nya böcker och skriva kommentarer etc. Kan ta bort sitt eget konto och information kopplat till det.

Adminanvändare - kan ta bort/editera böcker, kommentarer och användare.

## ER-Diagram

![Er-Diagram](./er_diagram.png?raw=true "ER-diagram")

## Gränssnittsskisser

**Login**

![Er-Diagram](./ui_login.png?raw=true "ER-diagram")

**Visa bok**

![Er-Diagram](./ui_show_book.png?raw=true "ER-diagram")
