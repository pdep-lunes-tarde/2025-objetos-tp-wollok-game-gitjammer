import shadowMantle.*
import wollok.game.*

object shadowMantle{
    // Configuración general
    const title = "Shadow Mantle"
    const tamano = 25
    
    method ancho() { return tamano }
    method alto() { return tamano }


    method configuracion(){
        game.width(self.ancho())
        game.height(self.alto())
        game.cellSize(40)
        game.title(title)
        
        mapa.grillaMax(tamano-1)
        game.boardGround("fondo.png")

        const musica = game.sound("OcarinaOfTime.mp3")
        musica.shouldLoop(true)
        musica.volume(0.25)
        game.schedule(1000, {musica.play()})

        // Jugador
        const maxHP = 3
        player.hp(maxHP)
        player.position(game.center())

        game.addVisual(player)
        game.showAttributes(player)

        
        // game.onTick(1000,"sumarpuntaje", {player.sumarPuntaje(10)})
        // game.onTick(100,"actualizarpuntaje", {puntaje.puntos(player.puntaje())})

        game.addVisual(puntaje)

        
        gameMaster.iniciar()

      

        keyboard.w().onPressDo{player.mover("arriba")}
        
        keyboard.s().onPressDo{player.mover("abajo")}

        keyboard.d().onPressDo{player.mover("derecha")}

        keyboard.a().onPressDo{player.mover("izquierda")}

        keyboard.space().onPressDo{player.atacar()}
        

        // Debug
        // game.onTick(1000, "debug2", {game.say(player, "HP: " + player.hp().toString())})
    }


    method iniciarJuego(){
        self.configuracion()
        game.start()
    }




}