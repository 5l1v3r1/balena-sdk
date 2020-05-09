import * as Promise from 'bluebird';
import * as PineClient from './pinejs-client-core';

/* tslint:disable:no-namespace */
declare namespace BalenaPine {
	interface Pine {
		delete<T>(
			params: PineClient.ParamsObjWithId<T> | PineClient.ParamsObjWithFilter<T>,
		): Promise<'OK'>;
		get<T>(
			params: PineClient.ParamsObjWithId<T>,
		): Promise<PineClient.TypedResult<T, Required<typeof params>['options']>>;
		get<T>(
			params: PineClient.ParamsObj<T>,
		): Promise<
			Array<PineClient.TypedResult<T, Required<typeof params>['options']>>
		>;
		get<T, Result>(params: PineClient.ParamsObj<T>): Promise<Result>;
		post<T>(params: PineClient.ParamsObj<T>): Promise<T>;
		patch<T>(
			params: PineClient.ParamsObjWithId<T> | PineClient.ParamsObjWithFilter<T>,
		): Promise<'OK'>;
		upsert<T>(params: PineClient.UpsertParams<T>): Promise<T | 'OK'>;
	}
}

declare function BalenaPine(options: object): BalenaPine.Pine;

export = BalenaPine;
