<template>
  <div id="app">
    <audio id="background-music" autoplay loop>
      <source :src="bgm" type="audio/mpeg">
      Your browser does not support the audio element.
    </audio>
    <div id="pageflip-container" style="background-image: url('/background.jpg'); background-size: cover; background-position: center;">
      <!-- First Cover Page -->
      <div class="page page-cover" data-density="hard">
        <h2>{{ pages[0].content.title }}</h2>
        <p>{{ pages[0].content.body }}</p>
      </div>

      <!-- Dynamic Pages -->
      <div v-for="(page, index) in pages.slice(1, pages.length - 1)" :key="index" class="page" :data-type="page.type">
        <div class="page-content">
          <h2>{{ page.content.title }}</h2>
          <p v-if="page.type === 'Text'">{{ page.content.body }}</p>
          <iframe v-if="page.type === 'Video'" :src="page.content.body" width="100%" height="100%" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
          <img v-if="page.type === 'Image'" :src="page.content.body" alt="Page image" style="max-width:100%; max-height:100%; object-fit:contain;">
        </div>
      </div>

      <!-- Last Cover Page -->
      <div class="page page-cover" data-density="hard">
        <h2>{{ pages[pages.length - 1].content.title }}</h2>
        <p>{{ pages[pages.length - 1].content.body }}</p>
      </div>
    </div>
    <div class="controls">
      <button id="audio-toggle" @click="toggleBgm">{{ isMuted ? 'Unmute' : 'Mute' }}</button>
      <button @click="flipPrev">Previous</button>
      <button @click="flipNext">Next</button>
      <select id="language-selector" @change="changeLanguage">
        <option value="en">English</option>
        <option value="kr">Korean</option>
        <option value="jp">Japanese</option>
        <option value="ch">Chinese</option>
      </select>
    </div>
  </div>
</template>

<script>
import { PageFlip } from 'page-flip';
import pagesData from '@/content/pages.json';

export default {
  name: 'App',
  data() {
    return {
      pageFlip: null,
      pages: pagesData,
      bgm: pagesData[0]?.bgm || '',
      isMuted: false,
      currentBgm: '',
    };
  },
  mounted() {
    this.$nextTick(() => {
      this.initPageFlip();
    });
  },
  methods: {
    initPageFlip() {
      const container = document.getElementById('pageflip-container');
      this.pageFlip = new PageFlip(container, {
        width: 550,
        height: 733,
        size: 'stretch',
        minWidth: 315,
        maxWidth: 1000,
        minHeight: 420,
        maxHeight: 1350,
        maxShadowOpacity: 0.5,
        flippingTime: 1500,
        showCover: true,
        mobileScrollSupport: false,
        usePortrait: true,
      });

      this.pageFlip.loadFromHTML(container.querySelectorAll('.page'));

      this.pageFlip.on('flip', () => {
        this.updateAudioState();
      });

      this.pageFlip.on('changeOrientation', (e) => {
        console.log(`Orientation changed to: ${e.data}`);
      });
    },
    flipNext() {
      this.pageFlip.flipNext();
    },
    flipPrev() {
      this.pageFlip.flipPrev();
    },
    updateAudioState() {
      const audioElement = document.getElementById('background-music');
      const currentPage = this.pageFlip.getCurrentPageIndex();
      const nextPage = currentPage + 1;
      const visiblePages = [currentPage, nextPage];
      let highestPriorityBgm = this.currentBgm;
      let shouldMute = false;

      visiblePages.forEach((pageIndex) => {
        const page = this.pages[pageIndex];
        if (page && page.type === 'Video') {
          shouldMute = true;
        }
        if (page && page.bgm && page.bgm > highestPriorityBgm) {
          highestPriorityBgm = page.bgm;
        }
      });

      if (shouldMute) {
        audioElement.pause();
      } else if (!this.isMuted && highestPriorityBgm !== this.currentBgm) {
        this.currentBgm = highestPriorityBgm; // Update current BGM without reloading
        if (audioElement.paused) {
          audioElement.play(); // Resume if paused
        }
      }

      console.log(`BGM: ${highestPriorityBgm}, Muted: ${shouldMute}`);
    },
    toggleBgm() {
      const audioElement = document.getElementById('background-music');
      this.isMuted = !this.isMuted;
      if (this.isMuted) {
        audioElement.pause();
      } else {
        audioElement.play();
      }
    },
  },
};
</script>

<style>
body {
  font-family: Arial, sans-serif;
  margin: 0;
  padding: 0;
}
#app {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  width: 100vw;
  overflow: hidden;
  background-color: #f4f4f4;
}
.controls {
  margin-top: 20px;
}
button {
  margin: 5px;
  padding: 10px 20px;
  cursor: pointer;
}
.flip-book {
  box-shadow: 0 0 20px 0 rgba(0, 0, 0, 0.5);
  display: none;
  background-size: cover;
}
.page {
  padding: 20px;
  background-color: hsl(35, 55%, 98%);
  color: #274C77;
  border: solid 1px hsl(35, 20%, 70%);
  overflow: hidden;
  font-family: 'Dancing Script', cursive;
  font-size: 1.1em;
  line-height: 1.6;
  text-align: center;
}
.page-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  width: 100%;
  text-align: center;
}
</style>
