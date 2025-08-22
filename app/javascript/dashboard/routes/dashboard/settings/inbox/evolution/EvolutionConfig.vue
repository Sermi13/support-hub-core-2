<script>
import { useAlert } from 'dashboard/composables';
import Spinner from 'shared/components/Spinner.vue';
import ConnectInstance from './components/ConnectInstance.vue';
import evolution from '../../../../../api/evolution';
import NextButton from 'dashboard/components-next/button/Button.vue';

export default {
  components: {
    ConnectInstance,
    Spinner,
    NextButton,
  },
  props: {
    inbox: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      instance: {},
      fetchError: '',
      isLoading: true,
      isDisconnecting: false,
      isConnectionPage: false,
    };
  },
  computed: {
    currentInboxId() {
      return this.$route.params.inboxId;
    },
    instanceName() {
      return this.inbox.integration_id;
    },
    mapStatus() {
      const statusMap = {
        open: this.$t('EVOLUTION_MGMT.INSTANCE.STATUS.OPEN'),
        connecting: this.$t('EVOLUTION_MGMT.INSTANCE.STATUS.CONNECTING'),
        closed: this.$t('EVOLUTION_MGMT.INSTANCE.STATUS.CLOSE'),
      };
      return (
        statusMap[this.instance.connectionStatus] ||
        this.$t('EVOLUTION_MGMT.INSTANCE.STATUS.UNKNOW')
      );
    },
  },
  async mounted() {
    await this.fetchInstanceDetails();
  },
  methods: {
    async disconnectInstance() {
      try {
        this.isDisconnecting = true;
        const response = await evolution.disconnect(this.inbox.integration_id);

        if (response.status < 200 && response.status > 299) {
          throw new Error('Failed to disconnect instance ');
        }
        this.instance.connectionStatus = 'closed';
        this.isConnectionPage = true;
        useAlert(this.$t('EVOLUTION_MGMT.EDIT.DISCONNECT.SUCCESS'));
      } catch (error) {
        useAlert(this.$t('EVOLUTION_MGMT.EDIT.DISCONNECT.ERROR'));
      } finally {
        this.isDisconnecting = false;
        await this.fetchInstanceDetails();
      }
    },
    connectionSuccessful() {
      this.isConnectionPage = false;
      this.instance.connectionStatus = 'open';
    },
    async fetchInstanceDetails() {
      try {
        this.isLoading = true;
        const response = await evolution.show(this.inbox.integration_id);

        if (response.status < 200 && response.status > 299) {
          throw new Error('Failed to fetch instance details');
        }
        this.instance = response.data[0] || {};

        if (this.instance.connectionStatus !== 'open') {
          this.isConnectionPage = true;
        }
      } catch (error) {
        this.fetchError = error.message;
        useAlert('Erro ao carregar configurações Evolution');
      } finally {
        this.isLoading = false;
      }
    },
  },
};
</script>

<template>
  <div v-if="!isConnectionPage">
    <div v-if="!isLoading">
      <div v-if="fetchError" class="text-red-500 p-4">
        {{ fetchError }}
      </div>

      <div v-if="!isLoading" class="h-full w-full">
        <div class="mb-8">
          <h2 class="text-xl font-semibold mb-4">
            {{ $t('EVOLUTION_MGMT.EDIT.CONFIGURATION') }}
          </h2>

          <div class="space-y-4">
            <div>
              <label
                class="block text-sm font-medium text-slate-700 dark:text-slate-300"
              >
                {{ $t('EVOLUTION_MGMT.EDIT.NAME') }}
              </label>
              <p class="mt-1 text-slate-900 dark:text-slate-100">
                {{ instance.name }}
              </p>
            </div>

            <div>
              <label
                class="block text-sm font-medium text-slate-700 dark:text-slate-300"
              >
                {{ $t('EVOLUTION_MGMT.EDIT.CONNECTION_STATUS') }}
              </label>
              <p class="mt-1 text-slate-900 dark:text-slate-100">
                <span
                  class="badge p-2 rounded-lg"
                  :class="{
                    'bg-green-100 text-green-800':
                      instance.connectionStatus === 'open',
                    'bg-red-100 text-red-800':
                      instance.connectionStatus === 'closed',
                    'bg-yellow-100 text-yellow-800':
                      instance.connectionStatus === 'connecting',
                  }"
                >
                  {{ mapStatus }}
                </span>
              </p>
            </div>
          </div>
        </div>

        <div class="flex space-x-4">
          <NextButton
            v-if="instance.connectionStatus !== 'open'"
            :loading="isDisconnecting"
            solid
            teal
            :label="$t('EVOLUTION_MGMT.EDIT.BUTTONS.RECONNECT')"
            @click="fetchInstanceDetails"
          />

          <NextButton
            v-if="instance.connectionStatus === 'open'"
            solid
            ruby
            :label="$t('EVOLUTION_MGMT.EDIT.BUTTONS.DISCONNECT')"
            @click="disconnectInstance"
          />
        </div>
      </div>
    </div>
    <div v-else class="mt-12 w-full flex justify-center">
      <Spinner size="medium" />
    </div>
  </div>

  <div
    v-else
    class="flex-grow flex-shrink w-full min-w-0 pl-0 pr-0 overflow-auto settings"
  >
    <ConnectInstance
      :instance_name="inbox.integration_id"
      @next="connectionSuccessful"
    />
  </div>
</template>
