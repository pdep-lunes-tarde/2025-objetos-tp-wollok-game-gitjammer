import wollok.game.*

// NOTA. TODOS LOS SPRITES SE HACEN INICIALMENTE EN 16X16, LUEGO SE REESCALAN A 200X200

// CLASE DE CharacterBody2D. DE ESTA HEREDAN EL JUGADOR Y LOS ENEMIGOS

class CharacterBody2D {
    var image = "goblinplaceholder.png"
    method image() = image
    method image(newImage) {image = newImage}
    method soyElJugador() { return false}
    // Salud
    var property hp = 1
    method cambiarHP(cantidad) { hp = hp + cantidad}
    // Posición y Dirección
    var property position = game.center() // por default es el centro. ESTO SE TIENE QUE CAMBIAR SI VAMOS A HACER ENEMIGOS, PARA QUE NO APAREZCAN EN EL CENTRO.
    method position(nuevaPosicion) {position = nuevaPosicion}
    var direccion = "abajo"
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
      self.morir()
      self.cambiarHP(-1)
    }
}


// Jugador.
class Player inherits CharacterBody2D{
    override method soyElJugador() {return true}
    // Imagen
    override method image() = "playerFront1.png"
    // Puntaje
    var property puntaje = 0
    method sumarPuntaje(cantidad) { puntaje = puntaje + cantidad} // Si quisiesemos restar puntaje al ser golpeados, deberíamos poner una cantidad negativa.
}

// Barra de puntaje
object puntaje {
     var property position = game.at(0,14)
     method position(nuevaPosicion) { position = nuevaPosicion}
     var puntos = 0
     method puntos(nuevoPuntaje) {
        puntos = nuevoPuntaje
     }
     method text() = "Puntaje: " + puntos.toString()
     method interactuar() {}
     method textColor() = "00000000"
}

// Enemigo.

class Enemy inherits CharacterBody2D{
    override method image() = "goblinplaceholder.png"
    method interactuar(entidad){
        if (entidad.soyElJugador()){
            entidad.tomarDaño()
            entidad.position(game.center())
            entidad.sumarPuntaje(-100)
            if (entidad.puntaje() -100 > 0) { entidad.puntaje(0) }
        }
    }
}

class Zombie inherits Enemy{
    var property direccionDelJugador = "abajo"
    method obtenerDireccionDelJugador(player){
        var diferenciaEnX = player.position().x() - self.position().x()
        var diferenciaEnY = player.position().y() - self.position().y()
        if (diferenciaEnX >= 0 && diferenciaEnY <= 0){ // Caso 1. Abajo a la derecha
            if (diferenciaEnX < diferenciaEnY.abs()){ self.direccionDelJugador("abajo") }
            else { self.direccionDelJugador("derecha")}
        }
        if (diferenciaEnX <= 0 && diferenciaEnY <= 0) { // Caso 2. Abajo a la izquierda
            if (diferenciaEnX.abs() < diferenciaEnY.abs()) { self.direccionDelJugador("abajo")}
            else { self.direccionDelJugador("izquierda")}
        }
        if (diferenciaEnX >= 0 && diferenciaEnY > 0){ // Caso 3. Arriba a la derecha{
            if (diferenciaEnX < diferenciaEnY){ self.direccionDelJugador("arriba")}
            else {self.direccionDelJugador("derecha")}
        }
        if (diferenciaEnX <= 0 && diferenciaEnY > 0){ // Caso 4. Arriba a la izquierda
            if (diferenciaEnX < diferenciaEnY.abs()) { self.direccionDelJugador("arriba")}
            else {self.direccionDelJugador("izquierda")}
        }
    }
    method moverseAlJugador(player){
        self.obtenerDireccionDelJugador(player)
        self.mover(direccionDelJugador)
    }
}