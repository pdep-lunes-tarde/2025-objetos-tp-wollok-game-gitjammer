import wollok.game.*

// NOTA. TODOS LOS SPRITES SE HACEN INICIALMENTE EN 16X16, LUEGO SE REESCALAN A 200X200

object player{
    // Imagen
    method image() = "playerplaceholderRESIZE.png"
    // Puntaje
    var puntaje = 0
    method puntaje() {return puntaje} 
    method cambiarPuntaje(cantidad) { puntaje = puntaje + cantidad} // Si quisiesemos restar puntaje al ser golpeados, deberíamos poner una cantidad negativa.
    // Salud
    var hp = 3
    method hp() { return hp }
    method cambiarHP(cantidad) { hp = hp + cantidad}
    // Posición y Dirección (esto va a servir para cuando pueda atacar)
    var property position = game.center() // seteamos posición inicial
    method position(nuevaPosicion) { position = nuevaPosicion }
    var direccion = "abajo"
    method direccion() {return direccion}
    method nuevaDireccion(nuevaDir) {
      direccion = nuevaDir    
    }

    // Movimiento
    method mover(direccionMovimiento) {
        if (direccionMovimiento == "arriba") {
            self.position( position.up(1) )
        }
        if (direccionMovimiento == "izquierda") {
            self.position ( position.left(1) )
        }
        if (direccionMovimiento == "derecha") {
            self.position ( position.right(1) )
        }
        if (direccionMovimiento == "abajo") {
            self.position ( position.down(1) )
        }
        self.nuevaDireccion(direccionMovimiento)
    }

}