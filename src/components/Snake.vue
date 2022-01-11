<script setup lang="ts">
import { ref, onMounted } from "vue";
let canvasRef = ref<HTMLCanvasElement | null>();
let self: SnakeGame;
interface Position {
  x: number;
  y: number;
}
class SnakeGame {
  cRef: HTMLCanvasElement | null;
  ctx: CanvasRenderingContext2D | null;
  unit: number;
  width: number;
  height: number;
  canvasColor: string;
  color2: string;
  snakeColor: string;
  snake: Position[];
  velocity: Position;
  setInterval: number;
  food: Position;
  constructor(
    unit = 20,
    width = window.innerWidth / 20,
    height = window.innerHeight / 20
  ) {
    self = this;
    this.cRef = canvasRef.value;
    this.ctx = null;
    this.unit = unit;
    this.width = width;
    this.height = height;
    this.canvasColor = "rgba(128, 128, 128, 0.3)";
    this.color2 = "rgba(128, 128, 128, 0.5)";
    this.snakeColor = "#00cc00";
    this.snake = [];
    this.velocity = { x: 1, y: 0 };
    this.setInterval = 0;
    this.food = { x: Math.random() * this.width, y: Math.random() * this.height };
  }
  start(): void {
    if (window.innerWidth >= 1080) this.unit = 30;
    else if (window.innerWidth >= 720) this.unit = 20;
    else this.unit = 15;
    this.cRef.width = window.innerWidth * 0.8;
    this.cRef.height = window.innerHeight * 0.8;
    this.width = Math.floor(this.cRef.width / this.unit) + 1;
    this.height = Math.floor(this.cRef.height / this.unit) + 1;
    let halfW = Math.floor(this.width / 2);
    let halfH = Math.floor(this.height / 2);
    this.snake.push({ x: halfW, y: halfH });
    this.snake.push({ x: halfW - 1, y: halfH });
    this.snake.push({ x: halfW - 2, y: halfH });
    this.snake.push({ x: halfW - 3, y: halfH });
    this.snake.push({ x: halfW - 4, y: halfH });
    this.randomizeFood();
    this.setInterval = setInterval(() => this.moveNext(), 300);
  }
  moveNext(): void {
    let newSnakePos: Position = { x: this.snake[0].x, y: this.snake[0].y };
    newSnakePos.x += this.velocity.x;
    newSnakePos.y += this.velocity.y;
    this.snake.unshift(newSnakePos);
    this.snake.pop();
    this.ctx?.clearRect(0, 0, this.width * this.unit, this.height * this.unit);
    this.draw();
  }
  moveLeft(): void {
    this.velocity = { x: -1, y: 0 };
  }
  moveRight(): void {
    this.velocity = { x: 1, y: 0 };
  }
  moveUp(): void {
    this.velocity = { x: 0, y: -1 };
  }
  moveDown(): void {
    this.velocity = { x: 0, y: 1 };
  }
  randomizeFood(): void {
    this.food = {
      x: Math.floor(Math.random() * this.width) - 2,
      y: Math.floor(Math.random() * this.height) - 2,
    };
    this.snake.forEach((snakePart) => {
      if (snakePart == this.food) {
        this.randomizeFood();
      }
    });
  }
  draw(): void {
    this.ctx = this.cRef.getContext("2d");
    this.ctx.fillStyle = this.color2;
    this.ctx.fillRect(0, 0, this.width * this.unit, this.height * this.unit);
    this.ctx.fillStyle = this.canvasColor;
    for (let i: number = 0; i < this.width; i += 1) {
      for (let j: number = 0; j < this.height; j += 1) {
        if ((i % 2 === 0 && j % 2 === 1) || (i % 2 === 1 && j % 2 === 0))
          this.ctx.fillRect(i * this.unit, j * this.unit, this.unit, this.unit);
      }
    }
    this.drawSnake();
    this.drawFood();
  }
  drawSnake(): void {
    this.ctx?.beginPath();
    this.ctx.fillStyle = this.snakeColor;
    this.snake.forEach((pos) => {
      this.ctx?.rect(pos.x * this.unit, pos.y * this.unit, this.unit, this.unit);
      this.ctx?.fill();
    });
    this.ctx?.closePath();
  }
  drawFood(): void {
    this.ctx.fillStyle = "#cc0000";
    this.ctx.fillRect(
      this.food.x * this.unit,
      this.food.y * this.unit,
      this.unit,
      this.unit
    );
  }
  arrowPressed(e: string): void {
    if (e.code === "ArrowUp") self.moveUp();
    else if (e.code === "ArrowDown") self.moveDown();
    else if (e.code === "ArrowLeft") self.moveLeft();
    else if (e.code === "ArrowRight") self.moveRight();
  }
}

onMounted(() => {
  const snake = new SnakeGame();
  document.addEventListener("keydown", snake.arrowPressed);
  snake.start();
});
</script>

<template>
  <div class="container">
    <canvas id="snakeCanvas" ref="canvasRef"> </canvas>
  </div>
</template>

<style scoped>
#snakeCanvas {
  border: 5px solid #000000;
  margin: 0;
  padding: 0;
  width: 80vw;
  height: 80vh;
}
.container {
  margin: 0;
  padding: 0;
  display: flex;
  align-items: center;
  align-content: center;
  justify-content: center;
  height: 100vh;
}
</style>
