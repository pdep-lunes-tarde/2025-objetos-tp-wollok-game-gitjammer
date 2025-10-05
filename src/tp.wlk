import wollok.game.*

// NOTA. TODOS LOS SPRITES SE HACEN INICIALMENTE EN 16X16, LUEGO SE REESCALAN A 200X200

object player{
    // Imagen
    method image() = "playerplaceholder.png"
    // Puntaje
    var puntaje = 0
    method puntaje() {return puntaje} 
    method cambiarPuntaje(cantidad) { puntaje = puntaje + cantidad} // Si quisiesemos restar puntaje al ser golpeados, deberíamos poner una cantidad negativa.
    // Salud
    var hp = 3
    method hp() { return hp }
    method cambiarHP(cantidad) { hp = hp + cantidad}
    // Posición
    var property position = game.center()   

}