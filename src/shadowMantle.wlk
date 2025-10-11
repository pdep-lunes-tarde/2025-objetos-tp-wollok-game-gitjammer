import wollok.game.*

// NOTA. TODOS LOS SPRITES SE HACEN INICIALMENTE EN 16X16, LUEGO SE REESCALAN A 200X200


class Node2D {
    var property position = game.origin() // por default es el oirgen de coordenadas. ESTO SE TIENE QUE CAMBIAR SI VAMOS A HACER ENEMIGOS.
    // Dirección
    var property direccion = "abajo"
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
        self.direccion(direccionMovimiento)
        }
    // Daño
}
// CLASE DE CharacterBody2D. DE ESTA HEREDAN EL JUGADOR Y LOS ENEMIGOS
class CharacterBody2D inherits Node2D{
    var image = "goblinplaceholder.png"
    method image() = image
    method image(newImage) {image = newImage}
    method soyElJugador() { return false}
    // Salud
    var property hp = 1
    method cambiarHP(cantidad) { hp = hp + cantidad}

    method morir() {
        if (hp -1 == 0){game.removeVisual(self)}
    }
    method tomarDaño() {
      self.morir()
      self.cambiarHP(-1)
    }
}

// Jugador.
object player inherits CharacterBody2D{
    override method soyElJugador() {return true}
    // Imagen
    override method image() = "playerFront1.png"
    // Puntaje
    var property puntaje = 0
    method sumarPuntaje(cantidad) { puntaje = puntaje + cantidad} // Si quisiesemos restar puntaje al ser golpeados, deberíamos poner una cantidad negativa.
    // Ataque
    method atacar() {
        var ataque = new Attack()
        ataque.position(self.position())
        ataque.mover(self.direccion())
        game.addVisual(ataque)
        game.onCollideDo(ataque, { otro => otro.serAtacado(ataque) })
        game.schedule(ataque.duracion(), {game.removeVisual(ataque)})
    }
}


class Attack inherits Node2D{
    method image() = "ataque.png"
    var property daño = 1
    var property duracion = 500 // Duración en milisegundos
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
    method serAtacado(ataque) {
      self.tomarDaño()
      gameMaster.spawnCount(gameMaster.spawnCount() - 1) // Decrementa el contador de enemigos vivos al morir uno
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
    method moverse(player){
        self.obtenerDireccionDelJugador(player)
        self.mover(direccionDelJugador)
    }
    method inicializar(player){
        game.onTick(500, "moverzombie", {self.moverse(player)})
        game.whenCollideDo(player, {otro => otro.interactuar(player)})
    }
}




// Juego
object gameMaster{
    var property spawnCount = 0
    const diccionarioEnemigos = new Dictionary()
    method generarDiccionario() {
      diccionarioEnemigos.put(1,"zombie")
      diccionarioEnemigos.put(2,"esqueleto")
      diccionarioEnemigos.put(3,"goblin")
    }
    method enemigoAleatorio() {
       var max = 1 // syncear con la cantidad de enemigos indexados (y que realmente existan)
       return diccionarioEnemigos.get(1.randomUpTo(max))
    }
    method randomSpawn(){
        var enemigoASpawnear = self.enemigoAleatorio()
        if (enemigoASpawnear == "zombie") {
            const zombie = new Zombie()
            const randX = 0.randomUpTo(14)
            const randY = 0.randomUpTo(14)
            zombie.position(game.at(randX, randY))
            game.addVisual(zombie)
            zombie.inicializar(player)
        }
        self.spawnCount(self.spawnCount()+1)
    }
    method iniciar(){
        game.onTick(1000, "spawn", {self.randomSpawn()})
        game.onTick(1000, "revisarSpawns", {self.revisarSpawns()})
    }
    method revisarSpawns() {
        if (self.spawnCount() > 5) {
            game.removeTickEvent("spawn")
        if (self.spawnCount() == 0){ // Esto no estaría funcionando. Revisar por qué. A lo mejor el spawnCount no se está reduciendo correctamente...
            self.iniciar()
        }
        }
    }


}