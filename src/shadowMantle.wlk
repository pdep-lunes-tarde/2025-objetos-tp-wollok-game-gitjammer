import wollok.game.*

// NOTA. TODOS LOS SPRITES SE HACEN INICIALMENTE EN 16X16, LUEGO SE REESCALAN A 200X200

// CLASE DE CharacterBody2D. DE ESTA HEREDAN EL JUGADOR Y LOS ENEMIGOS

class CharacterBody2D {
    var image = "goblinplaceholder.png"
    method image() = image
    method image(newImage) {image = newImage}
    method soyElJugador() { return false}
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
    // Daño
    method morir() {
        if (hp -1 == 0){game.removeVisual(self)}
    }
    method tomarDaño() {
      self.cambiarHP(-1)
      self.morir()
    }
}

// Jugador.
class Player inherits CharacterBody2D{
    override method soyElJugador() {return true}
    // Imagen
    override method image() = "playerFront1.png"
    // Puntaje
    var puntaje = 0
    method puntaje() {return puntaje} 
    method cambiarPuntaje(cantidad) { puntaje = puntaje + cantidad} // Si quisiesemos restar puntaje al ser golpeados, deberíamos poner una cantidad negativa.
}


// Enemigo.

class Enemy inherits CharacterBody2D{
    override method image() = "goblinplaceholder.png"
    method interactuar(entidad){
        if (entidad.soyElJugador()){
            entidad.tomarDaño()
            entidad.position(game.center())
        }
    }
}