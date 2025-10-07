import shadowMantle.*
import wollok.game.*

object shadowMantle{
    // Configuración general
    const title = "Shadow Mantle"
    const cuadrado = 15
    method ancho(){ return cuadrado }
    method alto() { return cuadrado }


    // Configuración al iniciar el juego.

    method configuracion(){
        game.width(self.ancho())
        game.height(self.alto())
        game.cellSize(200)
        game.title(title)
        

        // Jugador
        const maxHP = 3
        const player = new Player()
        player.cambiarHP(maxHP)
        game.addVisual(player)
        game.showAttributes(player)

        // Enemigo de prueba
        const enemigo = new Enemy()
        enemigo.position(game.origin())
        game.addVisual(enemigo)

        // Input Handling

        keyboard.w().onPressDo{player.mover("arriba")}

        keyboard.s().onPressDo{player.mover("abajo")}

        keyboard.d().onPressDo{player.mover("derecha")}

        keyboard.a().onPressDo{player.mover("izquierda")}

        // Collision Handling
        game.onCollideDo(player, {otro => otro.interactuar(player)})
    }


    method iniciarJuego(){
        self.configuracion()
        game.start()
    }




}