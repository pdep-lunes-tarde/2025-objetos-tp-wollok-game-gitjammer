import wollok.game.*

// NOTA. TODOS LOS SPRITES SE HACEN INICIALMENTE EN 16X16, LUEGO SE REESCALAN A 200X200

object mapa {
    const property grilla = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
}
class Node2D {
    
    var property position = game.origin() // por default es el oirgen de coordenadas. ESTO SE TIENE QUE CAMBIAR SI VAMOS A HACER ENEMIGOS.
    
    var property direccion = "abajo"
    
    method mover(direccionMovimiento) {
        if (direccionMovimiento == "arriba") {
            position = position.up(1)
        }
        if (direccionMovimiento == "izquierda") {
            position = position.left(1) 
        }
        if (direccionMovimiento == "derecha") {
            position = position.right(1)
        }
        if (direccionMovimiento == "abajo") {
            position = position.down(1)
        }
        self.direccion(direccionMovimiento)
    }

    // Daño
}



// CLASE DE CharacterBody2D. DE ESTA HEREDAN EL JUGADOR Y LOS ENEMIGOS
class CharacterBody2D inherits Node2D{
    var property image = "goblinplaceholder.png"
   
    method soyElJugador() {return false}
    // Salud
    var property hp = 1
    method cambiarHP(cantidad) { hp = hp + cantidad}

    method morir() {
            game.removeVisual(self)
            if (!self.soyElJugador()){
                gameMaster.enemigos.remove(self)
                puntaje.sumarPuntaje(10)
            }else{
                game.addVisual("¡Game Over!")
            }
    }

    method tomarDaño() {
        self.cambiarHP(-1)
        if (hp <= 0){
            self.morir()
        }
    }
}

// Jugador.
object player inherits CharacterBody2D(image = "playerFront1.png"){
    override method soyElJugador() {return true}

    method sumarPuntaje(cantidad) { 
        puntaje.sumarPuntaje(cantidad)
    } 

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
     
     var puntos = 0
     method puntos(nuevosPuntos){puntos = nuevosPuntos}

     method sumarPuntaje(puntajeASumar) {
        puntos = puntos + puntajeASumar
        if (puntos < 0) {self.puntos(0)}
     }

     method text() = "Puntaje: " + puntos.toString()
     method textColor() = "00000000"
}

// Enemigo.
class Enemy inherits CharacterBody2D(image = "goblinplaceholder.png"){

    method interactuar(entidad){
        if (entidad.soyElJugador()){
            entidad.tomarDaño()
            entidad.position(game.center())
            entidad.sumarPuntaje(-100)
        }
    }
    method serAtacado(ataque) {
      self.tomarDaño()
      gameMaster.spawnCount(gameMaster.spawnCount() - 1) // Decrementa el contador de enemigos vivos al morir uno
    }

    method seleccionarPosicion(rand1){
        
        const bordes = [ [mapa.grilla.anyOne(), 0], [mapa.grilla.anyOne(), 14], [0, mapa.grilla.anyOne()], [14, mapa.grilla.anyOne()] ]
        const posicion = bordes[rand1 - 1]
        const x = posicion[0]
        const y = posicion[1]
        self.position(game.at(x, y))
    
        /*
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
        
    */
    }
}

class Zombie inherits Enemy(image = "Zombie.png"){
    
    /*
    method obtenerDireccionDelJugador(){
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
    */

    method obtenerDireccionDelJugador() {
        const diferenciaEnX = player.position().x() - self.position().x()
        const diferenciaEnY = player.position().y() - self.position().y()

        if (diferenciaEnX.abs() > diferenciaEnY.abs()) {
            if (diferenciaEnX > 0) self.direccion("derecha") else self.direccion("izquierda")
        } else {
            if (diferenciaEnY > 0) self.direccion("abajo") else self.direccion("arriba")
        }
    }

    
    method moverse(){
        self.obtenerDireccionDelJugador()
        self.mover(self.direccion())
    }

    method inicializar(){
        self.seleccionarPosicion([1,2,3,4].anyOne())
        // game.onTick(500, "moverzombie", {self.moverse()})
        game.addVisual(self)
        game.whenCollideDo(self, {entidad => self.interactuar(entidad)}) // REVISAR
    }
}


class Skeleton inherits Enemy(image = "Skeleton.png"){

    method obtenerDireccionDelJugador(){
        const diferenciaEnY = player.position().y() - self.position().y()
        if (diferenciaEnY > 0){ self.direccion("arriba")}
        else { self.direccion("abajo")}
    }
    
    /*
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
    */
    method moverse(){
        if (self.position().y() != player.position().y()) {
            self.obtenerDireccionDelJugador()
            self.mover(direccion)
        } //else {
            //self.dispararFlecha()
        //}
    }
     
    method inicializar(){
        self.seleccionarPosicion([1,2].anyOne())
        // game.onTick(500, "moveresqueleto", {self.moverse()})
        game.addVisual(self)
        game.whenCollideDo(self, {entidad => self.interactuar(entidad)})
    }
   
}
    
class Goblin inherits Enemy(image = "Goblin.png", direccion = "derecha"){

    method obtenerDireccionDelJugador(){
        const diferenciaEnX = player.position().x() - self.position().x()
        if (diferenciaEnX >= 0){self.direccion("derecha")}
        else { self.direccion("izquierda")}
    }
    
    /*
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
    */
    
    /*
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
    */
    method moverse(){
        if (self.position().x() != player.position().x()) {
            self.obtenerDireccionDelJugador()
            self.mover(direccion)
        } //else {
            //self.dispararLanza()
        //}
    }
    method inicializar(){
        self.seleccionarPosicion([1,2].anyOne())
        // game.onTick(500, "movergoblin", {self.moverse()})
        game.addVisual(self)
        game.whenCollideDo(self, {entidad => self.interactuar(entidad)})
    }
    
}


// Juego
object gameMaster {
    var property spawnCount = 0
    var property enemigos = []

    method enemigoAleatorio() {
       return ["zombie", "skeleton", "goblin"].anyOne()
    }
    
    method randomSpawn(){
        const enemigoASpawnear = self.enemigoAleatorio()

        if (enemigoASpawnear == "zombie") {
            const zombie = new Zombie()

            zombie.inicializar()
            enemigos.add(zombie)
        }
        
        else {if (enemigoASpawnear == "skeleton") {
            const skeleton = new Skeleton()
            skeleton.inicializar()
            enemigos.add(skeleton)
        }
        else { if (enemigoASpawnear == "goblin") {
            const goblin = new Goblin()
            goblin.inicializar()
            enemigos.add(goblin)
            } }
        }
        
        self.spawnCount(self.spawnCount()+1)
    }
    
    method iniciar(){
        game.onTick(500, "moverEnemigos", {if (enemigos.size() > 0) enemigos.forEach({ e => e.moverse() }) } )
        game.onTick(1000, "revisarSpawns", {self.revisarSpawns()})
    }

    method spawnear(){
        game.onTick(1000, "spawn", {self.randomSpawn()})
    }

    method revisarSpawns() {
        if (self.spawnCount() > 5) game.removeTickEvent("spawn")
        if (self.spawnCount() == 0) self.spawnear()
    }
}
