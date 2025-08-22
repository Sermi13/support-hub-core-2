<!-- eslint-disable no-console -->
<script setup>
import { ref, computed } from 'vue';
import { useStore } from 'dashboard/composables/store';
import { useVuelidate } from '@vuelidate/core';
import { required } from '@vuelidate/validators';
import { useAlert } from 'dashboard/composables';
import { v4 as uuidv4 } from 'uuid';
import NextButton from 'dashboard/components-next/button/Button.vue';
import ToggleSwitch from 'dashboard/components-next/switch/Switch.vue';
import PageHeader from '../../../SettingsSubPageHeader.vue';
import evolution from '../../../../../../api/evolution';

const emit = defineEmits(['next']);

const store = useStore();

const channelName = ref('');
const webhookUrl = ref('');
const uiFlags = computed(() => store.getters['inboxes/getUIFlags']);

const shouldBeWebhookUrl = (value = '') =>
  value ? value.startsWith('http') : true;

const rules = {
  channelName: { required },
  webhookUrl: { shouldBeWebhookUrl },
};

// Evolution options:
const formData = ref({
  alwaysOnline: false,
  ignoreGroups: true,
  readMessages: true,
  signMessage: false,
  reopenConversation: true,
  importContacts: true,
});

// Loading states
const isSubmitting = ref(false);
const submissionError = ref(null);

const v$ = useVuelidate(rules, { channelName, webhookUrl });

const createChannel = async () => {
  v$.value.$touch();
  if (v$.value.$invalid) {
    return;
  }

  try {
    isSubmitting.value = true;
    const instanceName = uuidv4();

    const payload = {
      instance_name: instanceName,
      ignore_groups: formData.value.ignoreGroups,
      always_online: formData.value.alwaysOnline,
      read_messages: formData.value.readMessages,
      sign_message: formData.value.signMessage,
      reopen_conversation: formData.value.reopenConversation,
      import_contacts: formData.value.importContacts,
      channel_name: channelName.value,
    };

    const response = await evolution.create(payload);
    if (response.status === 403) {
      useAlert(this.$t('EVOLUTION_MGMT.CREATE_FLOW.CONFIG.ERRORS.CONFLICT'));
      throw new Error(
        this.$t('EVOLUTION_MGMT.CREATE_FLOW.CONFIG.ERRORS.CONFLICT')
      );
    }

    submissionError.value = '';

    store.dispatch('inboxes/get');
    console.log(response.data.id);
    console.log(response.data);
    emit('next', { instanceName, inboxId: response.data.id });
  } catch (error) {
    console.error(error);
    useAlert('Erro ao criar caixa de entrada');
  }
};
</script>

<template>
  <PageHeader
    header-title="Criar caixa de entrada"
    header-content="Integre o seu whatsapp não oficial com o Sendd!"
  />
  <form class="flex flex-wrap mx-0" @submit.prevent="createChannel">
    <div class="w-[65%] flex-shrink-0 flex-grow-0 max-w-[65%]">
      <label :class="{ error: v$.channelName.$error }">
        {{ $t('INBOX_MGMT.ADD.API_CHANNEL.CHANNEL_NAME.LABEL') }}
        <input
          v-model="channelName"
          type="text"
          :placeholder="
            $t('INBOX_MGMT.ADD.API_CHANNEL.CHANNEL_NAME.PLACEHOLDER')
          "
          @blur="v$.channelName.$touch"
        />
        <span v-if="v$.channelName.$error" class="message">
          {{ $t('INBOX_MGMT.ADD.API_CHANNEL.CHANNEL_NAME.ERROR') }}
        </span>
      </label>
    </div>

    <div class="space-y-2 w-[65%] flex-shrink-0 flex-grow-0 max-w-[65%]">
      <p>{{ $t('EVOLUTION_MGMT.CREATE_FLOW.CONFIG.FIELD_TITLE') }}</p>
      <label class="flex items-center space-x-2">
        <ToggleSwitch id="sla_bh" v-model="formData.alwaysOnline" />
        <span>{{
          $t('EVOLUTION_MGMT.CREATE_FLOW.CONFIG.FIELDS.ALWAYS_ONLINE')
        }}</span>
      </label>

      <label class="flex items-center space-x-2">
        <ToggleSwitch id="sla_bh" v-model="formData.ignoreGroups" />
        <span>{{
          $t('EVOLUTION_MGMT.CREATE_FLOW.CONFIG.FIELDS.IGNORE_GROUPS')
        }}</span>
      </label>

      <label class="flex items-center space-x-2">
        <ToggleSwitch id="sla_bh" v-model="formData.readMessages" />
        <span>{{
          $t('EVOLUTION_MGMT.CREATE_FLOW.CONFIG.FIELDS.READ_MESSAGES')
        }}</span>
      </label>

      <label class="flex items-center space-x-2">
        <ToggleSwitch id="sla_bh" v-model="formData.signMessage" />
        <span>{{
          $t('EVOLUTION_MGMT.CREATE_FLOW.CONFIG.FIELDS.SIGN_MESSAGE')
        }}</span>
      </label>

      <label class="flex items-center space-x-2">
        <ToggleSwitch id="sla_bh" v-model="formData.reopenConversation" />
        <span>{{
          $t('EVOLUTION_MGMT.CREATE_FLOW.CONFIG.FIELDS.REOPEN_CONVERSATION')
        }}</span>
      </label>
      <label class="flex items-center space-x-2">
        <ToggleSwitch id="sla_bh" v-model="formData.importContacts" />
        <span>{{
          $t('EVOLUTION_MGMT.CREATE_FLOW.CONFIG.FIELDS.IMPORT_CONTACTS')
        }}</span>
      </label>
    </div>
    <div class="w-full mt-4">
      <NextButton
        :is-loading="uiFlags.isCreating"
        type="submit"
        solid
        blue
        :label="$t('INBOX_MGMT.ADD.API_CHANNEL.SUBMIT_BUTTON')"
      />
    </div>
  </form>
</template>
