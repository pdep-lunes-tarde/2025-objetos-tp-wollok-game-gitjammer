import shadowMantle.*
import wollok.game.*

object shadowMantle{
    // Configuración general
    const title = "Shadow Mantle"
    const tamano = 15
    method ancho(){ return tamano }
    method alto() { return tamano }


    method configuracion(){
        game.width(self.ancho())
        game.height(self.alto())
        game.cellSize(200)
        game.title(title)
        

        // Jugador
        const maxHP = 3
        const player = new Player()
        player.hp(maxHP)
        game.addVisual(player)
        game.showAttributes(player)

        // Barra de puntaje
        game.onTick(1000,"sumarpuntaje", {player.sumarPuntaje(10)})
        game.onTick(100,"actualizarpuntaje", {puntaje.puntos(player.puntaje())})
        game.addVisual(puntaje)


        // Enemigo de prueba
        const enemigo = new Zombie()
        enemigo.position(game.at(0,0))
        game.addVisual(enemigo)

        // Input Handling

        keyboard.w().onPressDo{player.mover("arriba")}
        
        keyboard.s().onPressDo{player.mover("abajo")}

        keyboard.d().onPressDo{player.mover("derecha")}

        keyboard.a().onPressDo{player.mover("izquierda")}

        // Collision Handling
        game.onCollideDo(player, {otro => otro.interactuar(player)})

        // AI Handling
        game.onTick(500, "moverzombie", {enemigo.moverseAlJugador(player)})
        game.onTick(1000, "debug", {game.say(enemigo, enemigo.direccionDelJugador())})
        game.onTick(1000, "debug2", {game.say(player, "HP: " + player.hp().toString())})
    }


    method iniciarJuego(){
        self.configuracion()
        game.start()
    }




}