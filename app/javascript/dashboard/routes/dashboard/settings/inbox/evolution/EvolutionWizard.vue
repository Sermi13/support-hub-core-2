<script setup>
import { ref } from 'vue';
import { useI18n } from 'vue-i18n';
import InboxSetup from './components/InboxSetup.vue';
import ConnectInstance from './components/ConnectInstance.vue';
import Finish from './components/Finish.vue';
import AddAgent from './components/AddAgent.vue';

const { t } = useI18n();

const currentStep = ref(1);
const steps = [
  {
    title: t('EVOLUTION_MGMT.CREATE_FLOW.CONFIG.TITLE'),
    body: t('EVOLUTION_MGMT.CREATE_FLOW.CONFIG.BODY'),
    key: 'config',
  },
  {
    title: t('EVOLUTION_MGMT.CREATE_FLOW.CONNECT.TITLE'),
    body: t('EVOLUTION_MGMT.CREATE_FLOW.CONNECT.BODY'),
    key: 'connect',
  },
  {
    title: t('EVOLUTION_MGMT.CREATE_FLOW.ADD_AGENTS.TITLE'),
    body: t('EVOLUTION_MGMT.CREATE_FLOW.ADD_AGENTS.BODY'),
    key: 'add_agents',
  },
  {
    title: t('EVOLUTION_MGMT.CREATE_FLOW.FINISH.TITLE'),
    body: t('EVOLUTION_MGMT.CREATE_FLOW.FINISH.BODY'),
    key: 'finish',
  },
];

const instanceName = ref(null);
const inboxId = ref(null);

// Step navigation
const isActive = step => steps.indexOf(step) === currentStep.value - 1;
const isOver = step => steps.indexOf(step) < currentStep.value - 1;

const step1Next = data => {
  instanceName.value = data.instanceName;
  inboxId.value = data.inboxId;
  currentStep.value = 2;
};

const step2Next = () => {
  currentStep.value = 3;
};
const step3Next = () => {
  currentStep.value = 4;
};
</script>

<template>
  <div class="flex flex-row overflow-auto p-4 h-full">
    <div class="wizard-box">
      <transition-group name="wizard-items" tag="div">
        <div
          v-for="step in steps"
          :key="step.key"
          class="item"
          :class="{ active: isActive(step), over: isOver(step) }"
        >
          <div class="flex items-center">
            <h3
              class="text-slate-800 dark:text-slate-100 text-base font-medium pl-6 overflow-hidden whitespace-nowrap mb-1.5 text-ellipsis leading-tight"
            >
              {{ step.title }}
            </h3>
            <span
              v-if="isOver(step)"
              class="ml-1 text-green-500 dark:text-green-500"
            >
              <fluent-icon icon="checkmark" />
            </span>
          </div>
          <span class="step">
            {{ steps.indexOf(step) + 1 }}
          </span>
          <p class="pl-6 m-0 text-sm text-slate-600 dark:text-slate-300">
            {{ step.body }}
          </p>
        </div>
      </transition-group>
    </div>

    <div
      class="border border-slate-25 dark:border-slate-800/60 bg-white dark:bg-slate-900 h-full p-6 w-full max-w-full md:w-3/4 md:max-w-[75%] flex-shrink-0 flex-grow-0"
    >
      <!-- Step 1 Creating Inbox -->
      <InboxSetup v-if="currentStep === 1" @next="step1Next" />

      <!-- Step 2 Conecting Instance -->
      <ConnectInstance
        v-if="currentStep === 2"
        :instance_name="instanceName"
        @next="step2Next"
      />

      <!-- Step 3: Adding agents -->
      <AddAgent
        v-if="currentStep === 3"
        :inbox_id="inboxId"
        @next="step3Next"
      />
      <!-- Finish screen -->
      <Finish v-if="currentStep === 4" :inbox_id="inboxId" />
    </div>
  </div>
</template>

<style lang="scss" scoped>
.wizard-box {
  .item {
    @apply cursor-pointer after:bg-slate-75 before:bg-slate-75 dark:after:bg-slate-600 dark:before:bg-slate-600 py-4 pr-4 pl-6 relative before:h-4 before:top-0 last:before:h-0 first:before:h-0 last:after:h-0 before:content-[''] before:absolute before:w-0.5 after:content-[''] after:h-full after:absolute after:top-5 after:w-0.5;

    &.active {
      h3 {
        @apply text-woot-500 dark:text-woot-500;
      }

      .step {
        @apply bg-woot-500 dark:bg-woot-500;
      }
    }

    &.over {
      &::after {
        @apply bg-woot-500 dark:bg-woot-500;
      }

      .step {
        @apply bg-woot-500 dark:bg-woot-500;
      }

      & + .item {
        &::before {
          @apply bg-woot-500 dark:bg-woot-500;
        }
      }
    }

    .step {
      @apply bg-slate-75 dark:bg-slate-600 rounded-2xl font-medium w-4 left-4 leading-4 z-[999] absolute text-center text-white dark:text-white text-xxs top-5;
    }
  }
}
</style>
