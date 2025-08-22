<!-- eslint-disable no-console -->
<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import { useAlert } from 'dashboard/composables';
import PageHeader from '../../../SettingsSubPageHeader.vue';
import evolution from '../../../../../../api/evolution';

const props = defineProps({
  // eslint-disable-next-line vue/prop-name-casing
  instance_name: {
    type: String,
    default: '',
  },
});

const emit = defineEmits(['next']);

const qrcodeImage = ref(null);
const qrCodeInterval = ref(null);

const startQRCodePolling = async () => {
  try {
    const response = await evolution.connect(props.instance_name);

    if (response.status !== 200) throw new Error('Failed to fetch QR code');

    const { data } = await response;

    if (data.base64) {
      qrcodeImage.value = data.base64; // Update QR code
    }
  } catch (error) {
    console.error(error);
    useAlert('Falha ao pegar QR code de conexão');
  }

  qrCodeInterval.value = setInterval(async () => {
    try {
      const response = await evolution.connect(props.instance_name);

      if (response.status !== 200) throw new Error('Failed to fetch QR code');

      const { data } = await response;

      if (data.instance?.state === 'open') {
        clearInterval(qrCodeInterval.value);
        useAlert('Conectado com sucesso!');
        emit('next');
      }

      if (data.base64) {
        qrcodeImage.value = data.base64; // Update QR code
      }
    } catch (error) {
      console.error(error);
      useAlert(`Falha ao pegar o Qr code de conexão, ${error.message} `);
    }
  }, 5000); // Poll every 5 seconds
};

onMounted(() => {
  startQRCodePolling();
});
onUnmounted(() => {
  if (qrCodeInterval.value) {
    clearInterval(qrCodeInterval.value);
  }
});
</script>

<template>
  <PageHeader
    header-title="Conectar WhatsApp"
    header-content="Conecte utilizando o seu aplicativo whatsapp!"
  />
  <form class="flex flex-wrap mx-0" @submit.prevent="createChannel">
    <div class="w-full mt-8 text-center">
      <h2 class="text-xl font-semibold mb-4">
        {{ $t('EVOLUTION_MGMT.CREATE_FLOW.CONNECT.SUB_TITLE') }}
      </h2>

      <div v-if="qrcodeImage" class="mb-4">
        <img :src="qrcodeImage" alt="QR Code" class="mx-auto w-64 h-64" />
        <p class="text-sm text-gray-600 mt-2">
          {{ $t('EVOLUTION_MGMT.CREATE_FLOW.CONNECT.INST') }}
        </p>
      </div>
    </div>
  </form>
</template>
