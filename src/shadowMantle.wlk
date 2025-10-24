import wollok.game.*

// NOTA. TODOS LOS SPRITES SE HACEN INICIALMENTE EN 16X16, LUEGO SE REESCALAN A 200X200


class Node2D {
    const grilla = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
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
    var property image = "goblinplaceholder.png"
    method image() = image
    method image(newImage) {image = newImage}
    method soyElJugador() {return false}
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
        const ataque = new Attack()
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
    override method image() = "Zombie.png"
    var property direccionDelJugador = "abajo"
    method obtenerDireccionDelJugador(player){
        const diferenciaEnX = player.position().x() - self.position().x()
        const diferenciaEnY = player.position().y() - self.position().y()
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
    method seleccionarPosicion(rand1){
        if (rand1 == 1){ //Borde inferior
        const yCoor = 0
        const xCoor = grilla.anyOne()
        self.position(game.at(xCoor, yCoor))
        }
        else {if (rand1 == 2){ //Borde superior
        const yCoor = 14
        const xCoor = grilla.anyOne()
        self.position(game.at(xCoor, yCoor))
        }
        else {if (rand1 == 3){ //Borde izquierdo
        const yCoor = grilla.anyOne()
        const xCoor = 0
        self.position(game.at(xCoor, yCoor))
        }
        else {if(rand1 == 4){ //Borde derecho
        const yCoor = grilla.anyOne()
        const xCoor = 14
        self.position(game.at(xCoor, yCoor))
        }}}}
    }
    method moverse(player){
        self.obtenerDireccionDelJugador(player)
        self.mover(direccionDelJugador)
    }
    method inicializar(player){
        self.seleccionarPosicion([1,2,3,4].anyOne())
        game.onTick(500, "moverzombie", {self.moverse(player)})
        game.whenCollideDo(player, {otro => otro.interactuar(player)})
    }
}
class Skeleton inherits Enemy{
    override method image() = "Skeleton.png"
    var property direccionDelJugador = "izquierda"
    method obtenerDireccionDelJugador(player){
        const diferenciaEnY = player.position().y() - self.position().y()
        if (diferenciaEnY > 0){ self.direccionDelJugador("arriba")}
        else { self.direccionDelJugador("abajo")}
    }
    method seleccionarPosicion(rand1){
        if (rand1 == 1) //Borde Izquierdo
        {
            const yCoor = grilla.anyOne()
            const xCoor = 0
            self.position(game.at(xCoor, yCoor))
        }
        else {if (rand1 == 2) //Borde Derecho
        {
            const yCoor = grilla.anyOne()
            const xCoor = 14
            self.position(game.at(xCoor, yCoor))
        } }
    }
    method dispararFlecha(){
        const flecha = new Enemy() // Iba a incluir una clase de Flecha, pero creo que es innecesario ya que hace lo mismo que un enemigo.
        const duracion = 3500 // Que es ancho de la pantalla x velocidad a la que se va a mover (cada 250 ms)
        if (self.position().x() == 0) { // Si está en el borde izquierdo, dispara hacia la derecha
            flecha.position(self.position().right(1))
            flecha.image("arrowRight.png")
            game.schedule(250, flecha.mover("derecha"))
        }
        else { // Si está en el borde derecho, dispara hacia la izquierda
            flecha.position(self.position().left(1))
            flecha.image("arrowLeft.png")
            game.schedule(250, flecha.mover("izquierda"))
        }
        game.addVisual(flecha)
        game.onCollideDo(flecha, { otro => otro.interactuar(flecha) })
        game.onCollideDo(flecha, {flecha => game.removeVisual(flecha) })
        game.schedule(duracion, {game.removeVisual(flecha)})
    }
    method moverse(player){
        if (self.position().y() != player.position().y()) {
            self.obtenerDireccionDelJugador(player)
            self.mover(direccionDelJugador)
        } else {
            self.dispararFlecha()
        }
    }
    method inicializar(player){
        self.seleccionarPosicion([1,2].anyOne())
        game.onTick(500, "moveresqueleto", {self.moverse(player)})
        game.whenCollideDo(player, {otro => otro.interactuar(player)})
    }
}

class Goblin inherits Enemy{
    override method image() = "Goblin.png"
    var property direccionDelJugador = "arriba"
    method obtenerDireccionDelJugador(player){
        const diferenciaEnX = player.position().x() - self.position().x()
        if (diferenciaEnX >= 0){self.direccionDelJugador("derecha")}
        else { self.direccionDelJugador("izquierda")}
    }
    method seleccionarPosicion(rand1){
        if (rand1 == 1) //Borde Inferior
        {
            const xCoor = grilla.anyOne()
            const yCoor = 0
            self.position(game.at(xCoor, yCoor))
        }
        else {if (rand1 == 2) //Borde Superior
        {
            const xCoor = grilla.anyOne()
            const yCoor = 14
            self.position(game.at(xCoor, yCoor))
        } }
    }
    method dispararLanza(){
        const lanza = new Enemy()
        const duracion = 3500 // Que es alto de la pantalla x velocidad a la que se va a mover (cada 250 ms)
        if (self.position().y() == 0) { // Si está en el borde inferior, dispara hacia arriba
            lanza.position(self.position().up(1))
            lanza.image("spearUp.png")
            game.schedule(250, lanza.mover("arriba"))
        }
        else { // Si está en el borde superior, dispara hacia abajo
            lanza.position(self.position().down(1))
            lanza.image("spearDown.png")
            game.schedule(250, lanza.mover("abajo"))
        }
        game.addVisual(lanza)
        game.onCollideDo(lanza, { otro => otro.interactuar(lanza)})
        game.onCollideDo(lanza, {lanza => game.removeVisual(lanza)})
        game.schedule(duracion, {game.removeVisual(lanza)})
    }
    method moverse(player){
        if (self.position().x() != player.position().x()) {
            self.obtenerDireccionDelJugador(player)
            self.mover(direccionDelJugador)
        } else {
            self.dispararLanza()
        }
    }
    method inicializar(player){
        self.seleccionarPosicion([1,2].anyOne())
        game.onTick(500, "movergoblin", {self.moverse(player)})
        game.whenCollideDo(player, {otro => otro.interactuar(player)})
}}



// Juego
object gameMaster {
    var property spawnCount = 0
    method enemigoAleatorio() {
       return ["zombie", "esqueleto", "goblin"].anyOne()
    }
    method randomSpawn(){
        const enemigoASpawnear = self.enemigoAleatorio()
        if (enemigoASpawnear == "zombie") {
            const zombie = new Zombie()
            zombie.inicializar(player)
            game.addVisual(zombie)
        }
        else {if (enemigoASpawnear == "esqueleto") {
            const skeleton = new Skeleton()
            skeleton.inicializar(player)
            game.addVisual(skeleton)
        }
        else { if (enemigoASpawnear == "goblin") {
            const goblin = new Goblin()
            goblin.inicializar(player)
            game.addVisual(goblin)
            } }
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