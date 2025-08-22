/* global axios */

import ApiClient from './ApiClient';
class Evolution extends ApiClient {
  constructor() {
    super('evolution', { accountScoped: true });
  }

  connect(instance_name) {
    return axios.post(`${this.url}/connect`, { instance_name });
  }

  disconnect(instance_name) {
    return axios.post(`${this.url}/disconnect`, { instance_name });
  }
}

export default new Evolution();
