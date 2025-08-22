<script>
/* eslint no-console: 0 */
import { mapGetters } from 'vuex';
import { useAlert } from 'dashboard/composables';
import InboxMembersAPI from '../../../../../../api/inboxMembers';
import PageHeader from '../../../SettingsSubPageHeader.vue';
import NextButton from 'dashboard/components-next/button/Button.vue';
import { useVuelidate } from '@vuelidate/core';

export default {
  components: {
    PageHeader,
    NextButton,
  },
  props: {
    // eslint-disable-next-line vue/prop-name-casing
    inbox_id: {
      type: String,
      required: true,
    },
  },
  validations: {
    selectedAgents: {
      isEmpty() {
        return !!this.selectedAgents.length;
      },
    },
  },
  emits: ['next'],
  setup() {
    return { v$: useVuelidate() };
  },
  data() {
    return {
      selectedAgents: [],
      isCreating: false,
    };
  },
  computed: {
    ...mapGetters({
      agentList: 'agents/getAgents',
    }),
  },
  mounted() {
    this.$store.dispatch('agents/get');
  },
  methods: {
    async addAgents() {
      this.isCreating = true;
      const selectedAgents = this.selectedAgents.map(x => x.id);

      console.log(this.inbox_id);
      try {
        await InboxMembersAPI.update({
          inboxId: this.inbox_id,
          agentList: selectedAgents,
        });
        this.$emit('next');
      } catch (error) {
        useAlert(error.message);
      }
      this.isCreating = false;
    },
  },
};
</script>

<template>
  <form class="flex flex-wrap mx-0" @submit.prevent="addAgents()">
    <div class="w-full">
      <PageHeader
        :header-title="$t('INBOX_MGMT.ADD.AGENTS.TITLE')"
        :header-content="$t('INBOX_MGMT.ADD.AGENTS.DESC')"
      />
    </div>
    <div class="w-3/5">
      <div class="w-full">
        <label :class="{ error: v$.selectedAgents.$error }">
          {{ $t('INBOX_MGMT.ADD.AGENTS.TITLE') }}
          <multiselect
            v-model="selectedAgents"
            :options="agentList"
            track-by="id"
            label="name"
            multiple
            :close-on-select="false"
            :clear-on-select="false"
            hide-selected
            selected-label
            :select-label="$t('FORMS.MULTISELECT.ENTER_TO_SELECT')"
            :deselect-label="$t('FORMS.MULTISELECT.ENTER_TO_REMOVE')"
            :placeholder="$t('INBOX_MGMT.ADD.AGENTS.PICK_AGENTS')"
            @select="v$.selectedAgents.$touch"
          />
          <span v-if="v$.selectedAgents.$error" class="message">
            {{ $t('INBOX_MGMT.ADD.AGENTS.VALIDATION_ERROR') }}
          </span>
        </label>
      </div>
      <div class="w-full">
        <NextButton
          :is-loading="isCreating"
          type="submit"
          solid
          blue
          :label="$t('INBOX_MGMT.AGENTS.BUTTON_TEXT')"
        />
      </div>
    </div>
  </form>
</template>
