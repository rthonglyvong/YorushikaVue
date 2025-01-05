<template>
  <div id="app">
    <audio id="background-music" autoplay loop>
      <source :src="bgm" type="audio/mpeg">
      Your browser does not support the audio element.
    </audio>
    <button id="audio-toggle" @click="toggleBgm">{{ isMuted ? 'Unmute' : 'Mute' }}</button>
    <select id="language-selector" @change="changeLanguage">
      <option value="en">English</option>
      <option value="kr">Korean</option>
      <option value="jp">Japanese</option>
      <option value="ch">Chinese</option>
    </select>
    <div id="pageflip-container" style="background-image: url('/background.jpg'); background-size: cover; background-position: center;">
      <!-- First Cover Page -->
      <div class="page page-cover" data-density="hard">
        <h2>{{ pages[0]?.content.title }}</h2>
        <p>{{ pages[0]?.content.body }}</p>
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
        <h2>{{ pages[pages.length - 1]?.content.title }}</h2>
        <p>{{ pages[pages.length - 1]?.content.body }}</p>
      </div>
    </div>
    <div class="controls">
      <button @click="flipPrev">Previous</button>
      <button @click="flipNext">Next</button>
    </div>
  </div>
</template>

<script>
import { PageFlip } from 'page-flip';
import enPages from '@/content/pages.en.json';
import krPages from '@/content/pages.kr.json';
import jpPages from '@/content/pages.jp.json';
import chPages from '@/content/pages.ch.json';

export default {
  name: 'App',
  data() {
    return {
      pageFlip: null,
      pages: enPages,
      bgm: enPages[0]?.bgm || '',
      isMuted: false,
      currentBgm: '',
      currentLanguage: 'en',
      allPages: {
        en: enPages,
        kr: krPages,
        jp: jpPages,
        ch: chPages
      }
    };
  },
  mounted() {
    this.$nextTick(() => {
      this.initPageFlip();
    });
  },
  methods: {
    changeLanguage(event) {
      const selectedLanguage = event.target.value;
      this.currentLanguage = selectedLanguage;
      this.pages = this.allPages[selectedLanguage];
      this.bgm = this.pages[0]?.bgm || '';

      const currentPageIndex = this.pageFlip.getCurrentPageIndex();
      const wasMuted = this.isMuted;

      this.pageFlip.destroy();
      this.$nextTick(() => {
        this.initPageFlip();
        this.pageFlip.turnToPage(currentPageIndex);
      });
      this.isMuted = wasMuted;
      this.updateAudioState();
    },
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
        this.currentBgm = highestPriorityBgm;
        if (audioElement.paused) {
          audioElement.play();
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
