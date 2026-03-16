import request from '@/utils/request'

export function downloadTemplate() {
  return request({
    url: '/upload/template',
    method: 'get',
    responseType: 'blob'
  })
}

export function uploadExcel(data) {
  return request({
    url: '/upload/excel',
    method: 'post',
    data,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}
