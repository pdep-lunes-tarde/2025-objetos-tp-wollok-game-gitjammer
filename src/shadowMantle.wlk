import wollok.game.*

// NOTA. TODOS LOS SPRITES SE HACEN INICIALMENTE EN 16X16, LUEGO SE REESCALAN A 200X200

object mapa {
    var grillaMax = 24

    method grillaMax(nuevoMax) {
        grillaMax = nuevoMax
    } 
    method grillaMax() = grillaMax
}
class Visual {
    
    var property position = game.origin() // por default es el oirgen de coordenadas. ESTO SE TIENE QUE CAMBIAR SI VAMOS A HACER ENEMIGOS.
    
    var property image = "goblinplaceholder.png"
    
    method soyElJugador() {return false}
}



// CLASE DE CharacterBody2D. DE ESTA HEREDAN EL JUGADOR Y LOS ENEMIGOS
class Cuerpo2D inherits Visual{
    var activo = true

    method activo() = activo

    method activar() {activo = true}
    method desactivar() {activo = false}
    
    var property direccion = "abajo"

    
    // Salud
    var property hp = 1
    method cambiarHP(cantidad) { hp = hp + cantidad}

    method morir() {
            game.removeVisual(self)
            self.desactivar()
            if (!self.soyElJugador()){
                gameMaster.eliminarEnemigo(self)
                puntaje.sumarPuntaje(10)
            }else{
                game.removeTickEvent("spawn")
                game.removeTickEvent("moverEnemigos")
                game.removeVisual(puntaje)
                gameMaster.enemigos().forEach({enemigo => game.removeVisual(enemigo)})
                game.addVisual(gameOver)
                game.addVisual(puntaje)
            }
    }

    method tomarDaño() {
        self.cambiarHP(-1)
        if (hp <= 0){
            self.morir()
        }
    }

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
}

// Jugador.
object player inherits Cuerpo2D(image = "playerFront1.png"){
    override method soyElJugador() {return true}

    method sumarPuntaje(cantidad) { 
        puntaje.sumarPuntaje(cantidad)
    } 

    // Ataque
    method atacar() {
        if (self.activo()){
            attack.position(self.position())
            attack.mover(self.direccion())
            if(attack.activo()){
                game.removeVisual(attack)
            }
            game.addVisual(attack)
            attack.activar()
            game.onCollideDo(attack, { otro => if(!otro.soyElJugador()) otro.serAtacado() })
            game.schedule(attack.duracion(), {game.removeVisual(attack) attack.desactivar()})
        }
    }

    override method mover(direccionMovimiento) {
        var posicion = self.position()

        if (direccionMovimiento == "arriba") {
            if (posicion.y() + 1 <= mapa.grillaMax()) {
                posicion = position.up(1)
            }
        }
        else if (direccionMovimiento == "izquierda") {
            if (posicion.x() - 1 >= 0) {
                posicion = position.left(1)
            }
        } 
        else if (direccionMovimiento == "derecha") {
            if (posicion.x() + 1 <= mapa.grillaMax()){
                posicion = position.right(1)
            }
        }
        else if (direccionMovimiento == "abajo") {
            if (posicion.y() - 1 >= 0) {
                posicion = position.down(1)
            }
        }

    self.position(posicion)
    self.direccion(direccionMovimiento)
    }
}


object attack inherits Cuerpo2D (image = "ataqueAbajo.png"){

    override method image() {
        
        if(self.direccion() == "derecha" ) {return "ataqueDerecha.png"}
        else if(self.direccion() == "izquierda") {return "ataqueIzquierda.png"}
        else if(self.direccion() == "arriba") {return "ataqueArriba.png"}
        else {return "ataqueAbajo.png"}
    }

    method serAtacado() = false

    var property daño = 1
    var property duracion = 250 
}

object puntaje {
    var property position = game.at(1,mapa.grillaMax())
     
    var puntos = 0

    method soyElJugador() = false

    method puntos() = puntos
    method puntos(nuevosPuntos){puntos = nuevosPuntos}

    method sumarPuntaje(puntajeASumar) {
        puntos = puntos + puntajeASumar
        if (puntos < 0) {self.puntos(0)}
    }

    method text() = "Puntaje: " + puntos.toString()
    method textColor() = "FFFFFFFF"
}

object gameOver{
    var property position = game.origin()
    method image() = "gameOver.png"
    method soyElJugador() = false
}

class Pool { //maximo de objetos porque el garbage collector no estaria garbage collecteando y se empieza a laggear todo
    const objetos = []
    

    method objetos() = objetos

    method agregarObjeto(objeto){
        objetos.add(objeto)
    }



    method obtener() {
        return objetos.find({objeto => !objeto.activo()})
    }

    method activar(objeto) {
        objeto.activar()
    }

    method desactivar(objeto) {
        objeto.desactivar()
    }
}

object enemyPools {
    const zombies = new Pool()
    const skeletons = new Pool()
    const goblins = new Pool()

    method zombies() = zombies
    method skeletons() = skeletons
    method goblins() = goblins

    
    method agregarZombie(zombie){
        zombies.agregarObjeto(zombie)
    }

    method agregarSkeleton(skeleton) {
        skeletons.agregarObjeto(skeleton)
    }

    method agregarGoblin(goblin){
        goblins.agregarObjeto(goblin)
    }
    

    method obtenerZombie(){
        return zombies.obtener()
    }

    method obtenerSkeleton(){
        return skeletons.obtener()
    }

    method obtenerGoblin(){
        return goblins.obtener()
    }

}


class Enemy inherits Cuerpo2D(image = "goblinplaceholder.png"){
    
    var onCollide = false

    method onCollide() = onCollide
    method onCollideTrue(){ onCollide = true}

    method interactuar(entidad){
        if (self.activo() && entidad.soyElJugador()){
            entidad.position(game.center())
            entidad.tomarDaño()
            game.say(entidad, "AU")
            
        }
    }
    method serAtacado() {
        self.tomarDaño()
    }

    method seleccionarPosicion(rand1){

        
        if (rand1 == 1){ //Borde inferior
            const y = 0
            const x = 0.randomUpTo(mapa.grillaMax())
            self.position(game.at(x, y))
        }
        else if (rand1 == 2){ //Borde superior
            const y = mapa.grillaMax()
            const x = 0.randomUpTo(mapa.grillaMax())
            self.position(game.at(x, y))
        }
        else if (rand1 == 3){ //Borde izquierdo
            const y = 0.randomUpTo(mapa.grillaMax())
            const x = 0
            self.position(game.at(x, y))
        }
        else if(rand1 == 4){ //Borde derecho
            const y = 0.randomUpTo(mapa.grillaMax())
            const x = mapa.grillaMax()
            self.position(game.at(x, y))
        }
        
   
    }
}

class Zombie inherits Enemy(image = "Zombie.png"){
    
    method obtenerDireccionDelJugador() {
        const diferenciaEnX = player.position().x() - self.position().x()
        const diferenciaEnY = player.position().y() - self.position().y()

        if (diferenciaEnX.abs() > diferenciaEnY.abs()) {
            if (diferenciaEnX > 0) self.direccion("derecha") else self.direccion("izquierda")
        } else {
            if (diferenciaEnY > 0) self.direccion("arriba") else self.direccion("abajo")
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
        if(!self.onCollide()){
            game.whenCollideDo(self, {entidad => self.interactuar(entidad)}) 
        }
    }
}

class Proyectil inherits Enemy(image = "spearUp.png", direccion = "arriba"){

    method moverse(){
        self.mover(direccion)
        
        if (self.position().x() > mapa.grillaMax() || self.position().x() < 0 || self.position().y() > mapa.grillaMax() || self.position().y() < 0){
            game.removeVisual(self)
            gameMaster.eliminarProyectil(self)
            self.desactivar()
        }        
    }

    method collide(entidad){
        
        self.interactuar(entidad)
        game.removeVisual(self)
        gameMaster.eliminarEnemigo(self)
        self.desactivar()
    }
}
class Skeleton inherits Enemy(image = "Skeleton.png"){
    var cooldown = 0
    const projectilePool = new Pool()

    method cooldown (cuenta) {
        cooldown = cuenta
    }

    method obtenerDireccionDelJugador(){
        const diferenciaEnY = player.position().y() - self.position().y()
        if (diferenciaEnY > 0){ self.direccion("arriba")}
        else { self.direccion("abajo")}
    }
    
    
    method dispararFlecha(){
        var flecha
        if(projectilePool.objetos().size() < 2){
            flecha = new Proyectil()
            projectilePool.agregarObjeto( flecha )
        }else{
            flecha = projectilePool.obtener()
            flecha.activar()
        }
        
        if (self.position().x() == 0) { // Si está en el borde izquierdo, dispara hacia la derecha
            flecha.position(self.position().right(1))
            flecha.image("arrowRight.png")
            flecha.mover("derecha")
        }
        else { // Si está en el borde derecho, dispara hacia la izquierda
            flecha.position(self.position().left(1))
            flecha.image("arrowLeft.png")
            flecha.mover("izquierda")
        }
        game.addVisual(flecha)
        if(!flecha.onCollide()){     
            game.onCollideDo(flecha, { otro => flecha.collide(otro)})
            flecha.onCollideTrue()
        }
        gameMaster.agregarProyectil(flecha)
    }
    
    method moverse(){
        self.cooldown(cooldown + 1)
        if (cooldown >= 4 && (self.position().y() - player.position().y()).abs() <= 1) {
            self.dispararFlecha()
            self.cooldown(0)
        } else {
            self.obtenerDireccionDelJugador()
            self.mover(direccion)
        }
    }
     
    method inicializar(){
        self.seleccionarPosicion([3,4].anyOne())
        // game.onTick(500, "moveresqueleto", {self.moverse()})
        game.addVisual(self)
        if (!self.onCollide()){
            game.whenCollideDo(self, {entidad => self.interactuar(entidad)})
        }
    }
   
}


class Goblin inherits Enemy(image = "Goblin.png", direccion = "derecha"){
    var cooldown = 0
    const projectilePool = new Pool()

    method cooldown (cuenta) {
        cooldown = cuenta
    }

    method cooldown () = cooldown

    method obtenerDireccionDelJugador(){
        const diferenciaEnX = player.position().x() - self.position().x()
        if (diferenciaEnX > 0){self.direccion("derecha")}
        else { self.direccion("izquierda")}
    }
    
       
    method dispararLanza(){
        var lanza
        if (projectilePool.objetos().size() < 2){
            lanza = new Proyectil()
            projectilePool.agregarObjeto(lanza)
        }else{
            lanza = projectilePool.obtener()
            lanza.activar()
        }
        //const duracion = 3500 // Que es alto de la pantalla x velocidad a la que se va a mover (cada 250 ms)
        if (self.position().y() == 0) { // Si está en el borde inferior, dispara hacia arriba
            lanza.position(self.position().up(1))
        }
        else { // Si está en el borde superior, dispara hacia abajo
            lanza.position(self.position().down(1))
            lanza.image("spearDown.png")
            lanza.mover("abajo")
        }
        game.addVisual(lanza)
        if(!lanza.onCollide()){     
            game.onCollideDo(lanza, { otro => lanza.collide(otro)})
            lanza.onCollideTrue()
        }
        gameMaster.agregarProyectil(lanza)
        //game.schedule(duracion, {game.removeVisual(lanza)})
    }
    
    method moverse(){
        self.cooldown(cooldown + 1)
        if (cooldown >= 4 && (self.position().x() - player.position().x()).abs() <= 1) {
            self.dispararLanza()
            self.cooldown(0)
        } else {
            self.obtenerDireccionDelJugador()
            self.mover(direccion)
        }
    }

    method inicializar(){
        self.seleccionarPosicion([1,2].anyOne())
        // game.onTick(500, "movergoblin", {self.moverse()})
        game.addVisual(self)
        if(!self.onCollide()){
            game.whenCollideDo(self, {entidad => self.interactuar(entidad)})
        }
    }
    
}


// Juego
object gameMaster {
    var property enemigos = []
    var property proyectiles = []

    method agregarProyectil(nuevoProyectil){
        proyectiles.add(nuevoProyectil)
    }

    method eliminarProyectil(proyectil){
        proyectiles.remove(proyectil)
    }

    method enemigoAleatorio() {
       return ["zombie", "skeleton", "goblin"].anyOne()
    }

    method eliminarEnemigo(enemigo){
        enemigos.remove(enemigo) 
    }
    
    method randomSpawn(){
        const enemigoASpawnear = self.enemigoAleatorio()

        if (enemigoASpawnear == "zombie") {
            if(enemyPools.zombies().objetos().size() < 5){
                const zombie = new Zombie()

                enemyPools.agregarZombie(zombie)
                enemigos.add(zombie)
                zombie.inicializar()
            }else{
                const zombie = enemyPools.obtenerZombie()
                zombie.activar()
                enemigos.add(zombie)
                zombie.inicializar()
            }           
        }
        
        else if (enemigoASpawnear == "skeleton") {
            if(enemyPools.skeletons().objetos().size() < 5){
                const skeleton = new Skeleton()

                enemyPools.agregarSkeleton(skeleton)
                enemigos.add(skeleton)
                skeleton.inicializar()
            }else{
                const skeleton = enemyPools.obtenerSkeleton()
                skeleton.activar()
                enemigos.add(skeleton)
                skeleton.inicializar()
            }  
        }
        else if (enemigoASpawnear == "goblin") {
            if(enemyPools.goblins().objetos().size() < 5){
                const goblin = new Goblin()

                enemyPools.agregarGoblin(goblin)
                enemigos.add(goblin)
                goblin.inicializar()
            }else{
                const goblin = enemyPools.obtenerGoblin()
                goblin.activar()
                enemigos.add(goblin)
                goblin.inicializar()
            }  
        }

    }
    
    method iniciar(){
        game.onTick(500, "moverEnemigos", {if (enemigos.size() > 0) enemigos.forEach({ e => e.moverse() }) } )
        game.onTick(150, "moverProyectiles", {if (proyectiles.size() > 0) proyectiles.forEach({ e => e.moverse() }) })
        self.spawnear()
    }

    method spawnear(){
        game.onTick(1000, "spawn", {if (enemigos.size() < 5) self.randomSpawn()})
    }

    
}
