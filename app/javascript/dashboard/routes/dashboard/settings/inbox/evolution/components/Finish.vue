<script setup>
import { useI18n } from 'vue-i18n';
import EmptyState from '../../../../../../components/widgets/EmptyState.vue';
import NextButton from 'dashboard/components-next/button/Button.vue';

defineProps({
  inbox_id: {
    type: String,
    default: '',
  },
});

const { t } = useI18n();
</script>

<template>
  <div
    class="border border-slate-25 dark:border-slate-800/60 bg-white dark:bg-slate-900 h-full p-6 w-full max-w-full md:w-3/4 md:max-w-[75%] flex-shrink-0 flex-grow-0"
  >
    <EmptyState
      :title="t('INBOX_MGMT.FINISH.TITLE')"
      :message="t('INBOX_MGMT.FINISH.MESSAGE')"
      :button-text="t('INBOX_MGMT.FINISH.BUTTON_TEXT')"
    >
      <div class="flex justify-center gap-2 mt-4">
        <router-link
          :to="{
            name: 'settings_inbox_show',
            params: { inbox_id: inbox_id, inboxId: inbox_id },
          }"
        >
          <NextButton
            outline
            slate
            :label="$t('INBOX_MGMT.FINISH.MORE_SETTINGS')"
          />
        </router-link>
        <router-link
          :to="{
            name: 'inbox_dashboard',
            params: { inbox_id: inbox_id, inboxId: inbox_id },
          }"
        >
          <NextButton solid teal :label="$t('INBOX_MGMT.FINISH.BUTTON_TEXT')" />
        </router-link>
      </div>
    </EmptyState>
  </div>
</template>
