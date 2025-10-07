import wollok.game.*

// NOTA. TODOS LOS SPRITES SE HACEN INICIALMENTE EN 16X16, LUEGO SE REESCALAN A 200X200

// CLASE DE CharacterBody2D. DE ESTA HEREDAN EL JUGADOR Y LOS ENEMIGOS
class CharacterBody2D {
    // Imagen, por default usamos el goblin.
    method image() = "goblinplaceholder.png"
    // Salud
    var hp = 1
    method hp() {return hp}
    method cambiarHP(cantidad) { hp = hp + cantidad}
    // Posición y Dirección
    var property position = game.center() // por default es el centro. ESTO SE TIENE QUE CAMBIAR SI VAMOS A HACER ENEMIGOS, PARA QUE NO APAREZCAN EN EL CENTRO.
    method position(nuevaPosicion) {position = nuevaPosicion}
    var direccion = "null"
    method direccion() {return direccion}
    method nuevaDireccion(nuevaDir) { direccion = nuevaDir}
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

// Jugador.
class Player inherits CharacterBody2D{
    // Imagen
    override method image() = "playerplaceholderRESIZE.png"
    // Puntaje
    var puntaje = 0
    method puntaje() {return puntaje} 
    method cambiarPuntaje(cantidad) { puntaje = puntaje + cantidad} // Si quisiesemos restar puntaje al ser golpeados, deberíamos poner una cantidad negativa.
}
